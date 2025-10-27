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
    grafana = {
      source  = "grafana/grafana"
      version = "~> 2.6"
      }
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
  namespace                  = var.kubernetes_namespace
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

# Loki Deployment
module "loki" {
  source = "./modules/loki"

  namespace                   = kubernetes_namespace.observability.metadata[0].name
  storage_account_name        = module.storage.storage_account_name
  service_account_name        = var.service_account_name_loki
  workload_identity_client_id = module.workload_identity.app_application_id

  depends_on = [
    kubernetes_namespace.observability,
    module.workload_identity
  ]
}

# OpenTelemetry Collector Deployment
module "otel_collector" {
  source = "./modules/otel-collector"

  namespace        = kubernetes_namespace.observability.metadata[0].name
  helm_values_file = "${path.root}/modules/otel-collector/otel-collector-values.yaml"

  depends_on = [
    kubernetes_namespace.observability,
    module.loki,
    module.mimir,
    module.tempo
  ]
}

# Mimir Deployment
module "mimir" {
  source = "./modules/mimir"

  namespace                   = kubernetes_namespace.observability.metadata[0].name
  storage_account_name        = module.storage.storage_account_name
  service_account_name        = var.service_account_name_mimir
  workload_identity_client_id = module.workload_identity.app_application_id

  depends_on = [
    kubernetes_namespace.observability,
    module.workload_identity
  ]
}

# Tempo Deployment
module "tempo" {
  source = "./modules/tempo"

  namespace                   = kubernetes_namespace.observability.metadata[0].name
  storage_account_name        = module.storage.storage_account_name
  service_account_name        = var.service_account_name_tempo
  workload_identity_client_id = module.workload_identity.app_application_id

  depends_on = [
    kubernetes_namespace.observability,
    module.workload_identity
  ]
}

# Ingress for Unified Access to Observability Services
module "ingress" {
  source = "./modules/ingress"

  namespace                = kubernetes_namespace.observability.metadata[0].name
  ingress_class_name       = var.ingress_class_name
  host                     = var.ingress_host
  enable_tls               = var.ingress_enable_tls
  tls_secret_name          = var.ingress_tls_secret_name
  install_nginx_controller = var.ingress_install_nginx_controller

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
    module.tempo
  ]
}
# Grafana provisioning
provider "grafana" {
  url = "http://grafana-umbraco-dev-dns.westeurope.azurecontainer.io:3000/"
  auth = var.grafana_api_key
}

resource "grafana_data_source" "loki" {
  name = "Loki"
  type = "loki"
  url  = "http://loki.observability.svc.cluster.local:3100"
  is_default = false
}

resource "grafana_data_source" "tempo" {
  name = "Tempo"
  type = "tempo"
  url  = "http://tempo.observability.svc.cluster.local:3100"
}

resource "grafana_data_source" "mimir" {
  name = "Mimir"
  type = "prometheus"
  url  = module.loki.loki_url
}
