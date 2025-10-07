variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the Azure storage account"
  type        = string
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account"
  type        = string
}

variable "workload_identity_client_id" {
  description = "Client ID for workload identity"
  type        = string
}
