variable "namespace" {
  description = "Kubernetes namespace where cert-manager will be installed"
  type        = string
  default     = "cert-manager"
}

variable "create_namespace" {
  description = "Whether to create the namespace for cert-manager"
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "Version of the cert-manager Helm chart"
  type        = string
  default     = "v1.13.3"
}

variable "install_crds" {
  description = "Install cert-manager CRDs as part of the Helm release"
  type        = bool
  default     = true
}

variable "enable_prometheus_metrics" {
  description = "Enable Prometheus metrics for cert-manager"
  type        = bool
  default     = true
}

variable "replica_count" {
  description = "Number of cert-manager controller replicas"
  type        = number
  default     = 1
}

variable "webhook_replica_count" {
  description = "Number of cert-manager webhook replicas"
  type        = number
  default     = 1
}

variable "cainjector_replica_count" {
  description = "Number of cert-manager cainjector replicas"
  type        = number
  default     = 1
}
