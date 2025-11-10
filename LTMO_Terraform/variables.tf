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

variable "grafana_api_key" {
  type        = string
  description = "Grafana API key with admin or editor permissions"
  sensitive   = true
}

variable "cert_manager_version" {
  description = "Version of the cert-manager Helm chart"
  type        = string
  default     = "v1.13.3"
}
