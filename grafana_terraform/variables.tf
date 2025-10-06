variable "grafana_password" {
  description = "Password for grafana"
  type        = string
  sensitive = true
  default     = "admin"
}

variable "grafana_user" {
  description = "Username for grafana"
  type        = string
  sensitive = true
  default     = "admin"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "dns_name_label" {
  description = "DNS label for the container instance (must be globally unique)"
  type        = string
}
