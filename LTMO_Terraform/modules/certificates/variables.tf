variable "namespace" {
  description = "Kubernetes namespace where certificates will be created"
  type        = string
}

variable "ca_issuer_name" {
  description = "Name of the CA ClusterIssuer to use for signing certificates"
  type        = string
  default     = "observability-ca-issuer"
}

variable "base_domain" {
  description = "Base domain for service hostnames (e.g., observability.example.com)"
  type        = string
}

variable "region_name" {
  description = "Region identifier for this deployment (e.g., region-a, westeurope)"
  type        = string
  default     = "default"
}

variable "certificate_duration" {
  description = "Certificate validity duration"
  type        = string
  default     = "2160h" # 90 days
}

variable "certificate_renew_before" {
  description = "Renew certificate before expiry"
  type        = string
  default     = "720h" # 30 days
}

variable "enable_letsencrypt_ingress" {
  description = "Use Let's Encrypt for ingress TLS certificates instead of internal CA"
  type        = bool
  default     = false
}

variable "letsencrypt_issuer_name" {
  description = "Name of the Let's Encrypt ClusterIssuer (if enabled)"
  type        = string
  default     = "letsencrypt-prod"
}
