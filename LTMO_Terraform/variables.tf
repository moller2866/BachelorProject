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
  default     = 3
}

variable "node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "standard_b2pls_v2"
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

variable "loki_username" {
  description = "Username for Loki basic authentication"
  type        = string
  default     = "loki"
  sensitive   = true
}

variable "loki_password" {
  description = "Password for Loki basic authentication"
  type        = string
  default     = "admin"
  sensitive   = true
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
