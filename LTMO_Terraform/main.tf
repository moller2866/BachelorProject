terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.45"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 2.6"
    }
  }
}


provider "azurerm" {
  features {}
}

provider "azuread" {}

# Data source for current Azure subscription
data "azurerm_subscription" "current" {}

# Data source for current Azure AD configuration
data "azuread_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "observability" {
  name     = var.resource_group_name
  location = var.location

  tags = var.common_tags
}

# AKS Cluster
module "aks" {
  source = "./modules/aks"

  cluster_name        = var.aks_cluster_name
  resource_group_name = azurerm_resource_group.observability.name
  location            = azurerm_resource_group.observability.location
  node_count          = var.node_count
  node_vm_size        = var.node_vm_size

  tags = var.common_tags
}

# Storage Account for Loki
module "storage" {
  source = "./modules/storage"

  storage_account_name = var.storage_account_name
  resource_group_name  = azurerm_resource_group.observability.name
  location             = azurerm_resource_group.observability.location

  tags = var.common_tags
}

# Workload Identity Setup, needed for creating federated access tokens for accessing storage
module "workload_identity" {
  source = "./modules/workload-identity"

  app_display_name           = var.app_display_name
  aks_oidc_issuer_url        = module.aks.oidc_issuer_url
  loki_namespace             = "loki"
  mimir_namespace            = "mimir"
  tempo_namespace            = "tempo"
  service_account_name_loki  = var.service_account_name_loki
  service_account_name_mimir = var.service_account_name_mimir
  service_account_name_tempo = var.service_account_name_tempo
  storage_account_id         = module.storage.storage_account_id

  depends_on = [module.aks]
}

# Configure Kubernetes and Helm providers
provider "kubernetes" {
  host                   = module.aks.kube_config.host
  client_certificate     = base64decode(module.aks.kube_config.client_certificate)
  client_key             = base64decode(module.aks.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.aks.kube_config.host
    client_certificate     = base64decode(module.aks.kube_config.client_certificate)
    client_key             = base64decode(module.aks.kube_config.client_key)
    cluster_ca_certificate = base64decode(module.aks.kube_config.cluster_ca_certificate)
  }
}

# Kubernetes namespace
resource "kubernetes_namespace" "observability" {
  metadata {
    name = var.kubernetes_namespace
  }

  depends_on = [module.aks]
}

resource "kubernetes_namespace" "loki" {
  metadata {
    name = "loki"
  }

  depends_on = [module.aks]
}
resource "kubernetes_namespace" "mimir" {
  metadata {
    name = "mimir"
  }

  depends_on = [module.aks]
}
resource "kubernetes_namespace" "tempo" {
  metadata {
    name = "tempo"
  }

  depends_on = [module.aks]
}

resource "kubernetes_namespace" "otel_collector" {
  metadata {
    name = "otel-collector"
  }

  depends_on = [module.aks]
}

# NGINX Ingress Controller - deployed first to get the LoadBalancer IP
module "nginx_controller" {
  source = "./modules/nginx-controller"

  namespace          = kubernetes_namespace.observability.metadata[0].name
  chart_version      = var.nginx_controller_version
  ingress_class_name = var.ingress_class_name

  depends_on = [
    module.aks,
    kubernetes_namespace.observability
  ]
}

# cert-manager for certificate management
module "cert_manager" {
  source = "./modules/cert-manager"

  namespace                 = kubernetes_namespace.observability.metadata[0].name
  chart_version             = var.cert_manager_version
  install_crds              = true
  enable_prometheus_metrics = true

  # ClusterIssuer configuration
  ca_common_name = var.cert_manager_ca_common_name

  depends_on = [
    module.aks,
    kubernetes_namespace.observability
  ]
}

# Certificates for mTLS and TLS
module "certificates" {
  source = "./modules/certificates"

  namespace        = kubernetes_namespace.observability.metadata[0].name
  ca_issuer_name   = module.cert_manager.ca_issuer_name
  region_name      = var.certificates_region_name
  base_domain      = var.certificates_base_domain
  ingress_hostname = var.ingress_host # Use the same hostname as the ingress

  enable_ingress_tls       = var.certificates_enable_ingress_tls
  grafana_hostname         = var.grafana_hostname
  certificate_duration     = var.certificates_duration
  certificate_renew_before = var.certificates_renew_before
  # Dynamic: use ingress IP from nginx_controller module for nip.io hostname
  additional_dns_names = var.ingress_host == "" ? [module.nginx_controller.ingress_hostname_nip_io] : []

  depends_on = [
    kubernetes_namespace.observability,
    module.cert_manager,
    module.nginx_controller # Depends on nginx_controller to get the IP
  ]
}

# Wait for cert-manager to fully populate the certificate secrets
# This ensures the secrets contain actual certificate data before we try to read them
resource "null_resource" "wait_for_certificates" {
  count = var.grafana_datasources_enable_mtls ? 1 : 0

  depends_on = [module.certificates]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for Grafana client certificate secret to be ready..."
      kubectl wait --for=jsonpath='{.data.tls\.crt}' secret/${module.certificates.grafana_client_cert_secret} \
        -n ${kubernetes_namespace.observability.metadata[0].name} \
        --timeout=120s
      
      echo "Waiting for CA certificate secret to be ready..."
      kubectl wait --for=jsonpath='{.data.tls\.crt}' secret/${module.cert_manager.ca_secret_name} \
        -n ${module.cert_manager.namespace} \
        --timeout=120s
      
      echo "All certificate secrets are ready!"
    EOT
  }
}

# Loki Deployment
module "loki" {
  source = "./modules/loki"

  namespace                   = "loki"
  storage_account_name        = module.storage.storage_account_name
  service_account_name        = var.service_account_name_loki
  workload_identity_client_id = module.workload_identity.app_application_id

  depends_on = [
    kubernetes_namespace.loki,
    module.workload_identity
  ]
}

# OpenTelemetry Collector Deployment
module "otel_collector" {
  source = "./modules/otel-collector"

  namespace        = "otel-collector"
  helm_values_file = "${path.root}/modules/otel-collector/otel-collector-values.yaml"

  depends_on = [
    kubernetes_namespace.otel_collector,
    module.loki,
    module.mimir,
    module.tempo
  ]
}

# Mimir Deployment
module "mimir" {
  source = "./modules/mimir"

  namespace                   = "mimir"
  storage_account_name        = module.storage.storage_account_name
  service_account_name        = var.service_account_name_mimir
  workload_identity_client_id = module.workload_identity.app_application_id

  depends_on = [
    kubernetes_namespace.mimir,
    module.workload_identity
  ]
}

# Tempo Deployment
module "tempo" {
  source = "./modules/tempo"

  namespace                   = "tempo"
  storage_account_name        = module.storage.storage_account_name
  service_account_name        = var.service_account_name_tempo
  workload_identity_client_id = module.workload_identity.app_application_id

  depends_on = [
    kubernetes_namespace.tempo,
    module.workload_identity
  ]
}

# Ingress for Unified Access to Observability Services
module "ingress" {
  source = "./modules/ingress"

  namespace                = kubernetes_namespace.observability.metadata[0].name
  ingress_class_name       = var.ingress_class_name
  host                     = var.ingress_host != "" ? var.ingress_host : module.nginx_controller.ingress_hostname_nip_io
  enable_tls               = var.ingress_enable_tls
  tls_secret_name          = var.ingress_tls_secret_name
  install_nginx_controller = false # Controller is now deployed by nginx_controller module

  # mTLS configuration
  enable_mtls         = var.ingress_enable_mtls
  ca_secret_name      = module.cert_manager.ca_secret_name
  ca_secret_namespace = module.cert_manager.namespace
  mtls_verify_depth   = var.ingress_mtls_verify_depth

  # Service configuration
  loki_service_name  = "${module.loki.release_name}-gateway"
  loki_service_port  = 80
  mimir_service_name = "${module.mimir.release_name}-nginx"
  mimir_service_port = 80
  tempo_service_name = "${module.tempo.release_name}-gateway"
  tempo_service_port = 80

  depends_on = [
    kubernetes_namespace.observability,
    module.loki,
    module.mimir,
    module.tempo,
    module.cert_manager,
    module.certificates,      # Wait for TLS certificates to be created
    module.nginx_controller   # Wait for nginx controller to be ready
  ]
}

# Data sources to read certificate secrets for Grafana mTLS
data "kubernetes_secret" "grafana_client_cert" {
  count = var.grafana_datasources_enable_mtls ? 1 : 0

  metadata {
    name      = module.certificates.grafana_client_cert_secret
    namespace = kubernetes_namespace.observability.metadata[0].name
  }

  depends_on = [
    module.certificates,
    null_resource.wait_for_certificates
  ]
}

data "kubernetes_secret" "ingress_tls_cert" {
  count = var.ingress_enable_tls ? 1 : 0

  metadata {
    name      = module.certificates.ingress_tls_secret
    namespace = kubernetes_namespace.observability.metadata[0].name
  }

  depends_on = [
    module.certificates,
    null_resource.wait_for_certificates
  ]
}

data "kubernetes_secret" "ca_cert" {
  count = var.grafana_datasources_enable_mtls ? 1 : 0

  metadata {
    name      = module.cert_manager.ca_secret_name
    namespace = module.cert_manager.namespace
  }

  depends_on = [
    module.cert_manager,
    null_resource.wait_for_certificates
  ]
}

# Grafana provisioning
provider "grafana" {
  url  = var.grafana_hostname != "" ? "http://${var.grafana_hostname}:3000" : "http://grafana-umbraco-dev-dns.westeurope.azurecontainer.io:3000/"
  auth = var.grafana_api_key
}
module "grafana-provisioning" {
  source = "./modules/grafana-provisioning"

  # Use the dynamic hostname from nginx_controller or the configured ingress_host
  loki_url  = "https://${var.ingress_host != "" ? var.ingress_host : module.nginx_controller.ingress_hostname_nip_io}/loki"
  tempo_url = "https://${var.ingress_host != "" ? var.ingress_host : module.nginx_controller.ingress_hostname_nip_io}/tempo"
  mimir_url = "https://${var.ingress_host != "" ? var.ingress_host : module.nginx_controller.ingress_hostname_nip_io}/mimir/prometheus"

  # mTLS configuration
  enable_mtls         = var.grafana_datasources_enable_mtls
  tls_skip_verify     = var.grafana_datasources_tls_skip_verify
  grafana_client_cert = var.grafana_datasources_enable_mtls ? data.kubernetes_secret.grafana_client_cert[0].data["tls.crt"] : ""
  grafana_client_key  = var.grafana_datasources_enable_mtls ? data.kubernetes_secret.grafana_client_cert[0].data["tls.key"] : ""
  ca_cert             = var.grafana_datasources_enable_mtls ? data.kubernetes_secret.ca_cert[0].data["tls.crt"] : ""

  depends_on = [
    module.ingress,
    module.nginx_controller,
    data.kubernetes_secret.grafana_client_cert,
    data.kubernetes_secret.ca_cert
  ]

}

# K8s Monitoring for meta-monitoring of the observability stack
module "k8s_monitoring" {
  count  = var.k8s_monitoring_enabled ? 1 : 0
  source = "./modules/k8s-monitoring"

  namespace = kubernetes_namespace.observability.metadata[0].name

  # Chart configuration
  cluster_name    = var.k8s_monitoring_cluster_name
  scrape_interval = var.k8s_monitoring_scrape_interval

  # Feature toggles
  enable_cluster_events  = var.k8s_monitoring_enable_cluster_events
  enable_pod_logs        = var.k8s_monitoring_enable_pod_logs
  enable_cluster_metrics = var.k8s_monitoring_enable_cluster_metrics

  depends_on = [
    kubernetes_namespace.observability,
    module.loki,
    module.mimir,
    module.tempo
  ]
}

