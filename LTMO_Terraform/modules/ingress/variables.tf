variable "namespace" {
  description = "Kubernetes namespace for the ingress"
  type        = string
}

variable "ingress_class_name" {
  description = "Name of the IngressClass to use"
  type        = string
  default     = "nginx"
}

variable "host" {
  description = "Optional hostname for the ingress. If not provided, will use IP-based access"
  type        = string
  default     = ""
}

variable "enable_tls" {
  description = "Enable TLS/HTTPS for the ingress"
  type        = bool
  default     = false
}

variable "tls_secret_name" {
  description = "Name of the Kubernetes secret containing TLS certificate (required if enable_tls is true)"
  type        = string
  default     = "observability-tls"
}

variable "install_nginx_controller" {
  description = "Whether to install NGINX Ingress Controller via Helm"
  type        = bool
  default     = true
}

variable "nginx_controller_version" {
  description = "Version of the NGINX Ingress Controller Helm chart"
  type        = string
  default     = "4.11.3"
}

variable "additional_annotations" {
  description = "Additional annotations to add to the ingress"
  type        = map(string)
  default     = {}
}

variable "loki_service_name" {
  description = "Name of the Loki gateway service"
  type        = string
  default     = "loki-gateway"
}

variable "loki_service_port" {
  description = "Port of the Loki gateway service"
  type        = number
  default     = 80
}

variable "mimir_service_name" {
  description = "Name of the Mimir nginx service"
  type        = string
  default     = "mimir-nginx"
}

variable "mimir_service_port" {
  description = "Port of the Mimir nginx service"
  type        = number
  default     = 80
}

variable "tempo_service_name" {
  description = "Name of the Tempo gateway service"
  type        = string
  default     = "tempo-gateway"
}

variable "tempo_service_port" {
  description = "Port of the Tempo gateway service"
  type        = number
  default     = 80
}
