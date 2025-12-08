variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-observability-demo"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "westeurope"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "observability-demo-aks"
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
}

variable "node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique)"
  type        = string
  default     = "saobservabilitydemo"
}

variable "app_display_name" {
  description = "Display name for the Azure AD application"
  type        = string
  default     = "observability"
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for observability stack"
  type        = string
  default     = "observability"
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account"
  type        = string
  default     = "observability"
}

variable "service_account_name_loki" {
  description = "Name of the Kubernetes service account for Loki"
  type        = string
  default     = "loki"
}

variable "service_account_name_mimir" {
  description = "Name of the Kubernetes service account for Mimir"
  type        = string
  default     = "mimir"
}

variable "service_account_name_tempo" {
  description = "Name of the Kubernetes service account for Tempo"
  type        = string
  default     = "tempo"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Demo"
    ManagedBy   = "Terraform"
    Project     = "Observability"
  }
}

variable "ingress_install_nginx_controller" {
  description = "Whether to install NGINX Ingress Controller via Helm"
  type        = bool
  default     = true
}

variable "ingress_class_name" {
  description = "Name of the IngressClass to use for the observability ingress"
  type        = string
  default     = "nginx"
}

variable "ingress_host" {
  description = "Optional hostname for the ingress (if using DNS). Leave empty for IP-based access"
  type        = string
  default     = ""
}

variable "ingress_enable_tls" {
  description = "Enable TLS/HTTPS for the ingress"
  type        = bool
  default     = false
}

variable "ingress_tls_secret_name" {
  description = "Name of the Kubernetes secret containing TLS certificate (required if ingress_enable_tls is true)"
  type        = string
  default     = "observability-tls"
}

variable "ingress_enable_mtls" {
  description = "Enable mTLS client certificate verification on the ingress"
  type        = bool
  default     = false
}

variable "ingress_mtls_verify_depth" {
  description = "Verification depth for client certificates (how many CAs in the chain to verify)"
  type        = number
  default     = 1
}

# Grafana Datasource Configuration
variable "grafana_datasources_enable_mtls" {
  description = "Enable mTLS client certificate authentication for Grafana datasources"
  type        = bool
  default     = false
}

variable "grafana_datasources_tls_skip_verify" {
  description = "Skip TLS certificate verification for Grafana datasources (useful for self-signed certificates)"
  type        = bool
  default     = true
}

variable "grafana_api_key" {
  description = "Grafana API key with admin or editor permissions"
  type        = string
  sensitive   = true
}

variable "cert_manager_version" {
  description = "Version of the cert-manager Helm chart"
  type        = string
  default     = "v1.13.3"
}

variable "cert_manager_enable_letsencrypt" {
  description = "Enable Let's Encrypt ClusterIssuer for public TLS certificates"
  type        = bool
  default     = false
}

variable "cert_manager_letsencrypt_email" {
  description = "Email address for Let's Encrypt certificate notifications (required if enable_letsencrypt is true)"
  type        = string
  default     = ""
}

variable "cert_manager_letsencrypt_server" {
  description = "Let's Encrypt server URL (production or staging)"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "cert_manager_ca_common_name" {
  description = "Common Name for the self-signed root CA certificate"
  type        = string
  default     = "Observability Root CA"
}

variable "certificates_region_name" {
  description = "Region name for certificate hostnames (e.g., westeurope, eastus)"
  type        = string
  default     = "region-a"
}

variable "certificates_base_domain" {
  description = "Base domain for ingress hostnames (e.g., observability.example.com). Leave empty for IP-based access"
  type        = string
  default     = ""
}

variable "certificates_enable_ingress_tls" {
  description = "Create TLS certificates for ingress endpoints (requires base_domain)"
  type        = bool
  default     = true
}

variable "certificates_duration" {
  description = "Duration for certificate validity (e.g., 2160h = 90 days)"
  type        = string
  default     = "2160h0m0s"
}

variable "certificates_renew_before" {
  description = "Renew certificate before expiry (e.g., 720h = 30 days)"
  type        = string
  default     = "720h0m0s"
}

variable "grafana_namespace" {
  description = "Kubernetes namespace where Grafana is deployed"
  type        = string
  default     = "default"
}

variable "grafana_hostname" {
  description = "Hostname where Grafana is running (e.g., grafana-umbraco-dev-dns.westeurope.azurecontainer.io)"
  type        = string
  default     = ""
}

# K8s Monitoring Configuration
variable "k8s_monitoring_enabled" {
  description = "Enable k8s-monitoring for meta-monitoring of the observability stack"
  type        = bool
  default     = true
}

variable "k8s_monitoring_cluster_name" {
  description = "Cluster name for k8s-monitoring telemetry labels"
  type        = string
  default     = "lgtm-cluster"
}

variable "k8s_monitoring_scrape_interval" {
  description = "Scrape interval for k8s-monitoring metrics collection"
  type        = string
  default     = "15s"
}

variable "k8s_monitoring_enable_cluster_events" {
  description = "Enable cluster events collection in k8s-monitoring"
  type        = bool
  default     = true
}

variable "k8s_monitoring_enable_pod_logs" {
  description = "Enable pod logs collection in k8s-monitoring"
  type        = bool
  default     = true
}

variable "k8s_monitoring_enable_cluster_metrics" {
  description = "Enable cluster metrics collection in k8s-monitoring"
  type        = bool
  default     = true
}
