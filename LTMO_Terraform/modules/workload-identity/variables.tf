variable "app_display_name" {
  description = "Display name for the Azure AD application"
  type        = string
}

variable "aks_oidc_issuer_url" {
  description = "OIDC issuer URL from AKS"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "service_account_name" {
  description = "Kubernetes service account name"
  type        = string
}

variable "storage_account_id" {
  description = "ID of the storage account"
  type        = string
}
