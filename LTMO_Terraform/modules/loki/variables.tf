variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the Azure storage account"
  type        = string
}

variable "loki_chunk_container" {
  description = "Name of the Loki chunks container"
  type        = string
}

variable "loki_ruler_container" {
  description = "Name of the Loki ruler container"
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
