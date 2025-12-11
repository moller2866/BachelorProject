variable "namespace" {
  description = "Kubernetes namespace for the NGINX ingress controller"
  type        = string
}

variable "chart_version" {
  description = "Version of the NGINX Ingress Controller Helm chart"
  type        = string
  default     = "4.11.3"
}

variable "ingress_class_name" {
  description = "Name of the IngressClass to create"
  type        = string
  default     = "nginx"
}
