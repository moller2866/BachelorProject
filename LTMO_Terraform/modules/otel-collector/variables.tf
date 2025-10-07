variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "helm_values_file" {
  description = "Path to the Helm values file"
  type        = string
}
