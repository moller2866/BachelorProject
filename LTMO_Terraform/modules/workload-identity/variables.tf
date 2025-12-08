variable "app_display_name" {
  description = "Display name for the Azure AD application"
  type        = string
}

variable "aks_oidc_issuer_url" {
  description = "OIDC issuer URL from AKS"
  type        = string
}

variable "loki_namespace" {
  description = "Kubernetes loki namespace"
  type        = string
}
variable "mimir_namespace" {
  description = "Kubernetes mimir namespace"
  type        = string
}
variable "tempo_namespace" {
  description = "Kubernetes tempo namespace"
  type        = string
}

variable "service_account_name_loki" {
  description = "Kubernetes service account name for Loki"
  type        = string
}

variable "service_account_name_mimir" {
  description = "Kubernetes service account name for Mimir"
  type        = string
}

variable "service_account_name_tempo" {
  description = "Kubernetes service account name for Tempo"
  type        = string
}

variable "storage_account_id" {
  description = "ID of the storage account"
  type        = string
}
