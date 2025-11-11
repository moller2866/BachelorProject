variable "namespace" {

  description = "Kubernetes namespace where certificates will be created"
  type        = string
}

variable "ca_issuer_name" {
  description = "Name of the CA ClusterIssuer to use for signing certificates"
  type        = string
  default     = "observability-ca-issuer"
}

variable "region_name" {
  description = "Name of the region (used in certificate hostnames)"
  type        = string
  default     = "region-a"
}

variable "base_domain" {
  description = "Base domain for ingress hostnames (e.g., observability.example.com)"
  type        = string
  default     = ""
}

variable "ingress_hostname" {
  description = "Full hostname for the unified ingress (e.g., observability.example.com). If empty, will use 'observability-{region}.{base_domain}'"
  type        = string
  default     = ""
}

variable "certificate_duration" {
  description = "Duration for certificate validity (e.g., 2160h = 90 days)"
  type        = string
  default     = "2160h0m0s" # 90 days
}

variable "certificate_renew_before" {
  description = "Renew certificate before expiry (e.g., 720h = 30 days)"
  type        = string
  default     = "720h0m0s" # 30 days
}

variable "enable_ingress_tls" {
  description = "Create TLS certificates for ingress endpoints"
  type        = bool
  default     = true
}

variable "grafana_hostname" {
  description = "Hostname where Grafana is running (e.g., grafana-umbraco-dev-dns.westeurope.azurecontainer.io). Used for client certificate DNS names."
  type        = string
  default     = ""
}
