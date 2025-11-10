variable "loki_url" {
  description = "URL for the Loki data source"
  type        = string
}

variable "mimir_url" {
  description = "URL for the Mimir data source"
  type        = string
}

variable "tempo_url" {
  description = "URL for the Tempo data source"
  type        = string
}

# mTLS Configuration
variable "enable_mtls" {
  description = "Enable mTLS client certificate authentication for datasources"
  type        = bool
  default     = false
}

variable "tls_skip_verify" {
  description = "Skip TLS certificate verification (set to true for self-signed certificates)"
  type        = bool
  default     = true
}

variable "grafana_client_cert" {
  description = "PEM-encoded client certificate for mTLS authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "grafana_client_key" {
  description = "PEM-encoded client private key for mTLS authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ca_cert" {
  description = "PEM-encoded CA certificate for verifying server certificates"
  type        = string
  default     = ""
  sensitive   = true
}

