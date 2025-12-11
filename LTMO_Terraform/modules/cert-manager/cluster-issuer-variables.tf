variable "ca_common_name" {
  description = "Common Name for the self-signed CA certificate"
  type        = string
  default     = "Observability Root CA"
}

variable "ca_duration" {
  description = "Duration for CA certificate validity (in hours)"
  type        = string
  default     = "2160h0m0s" # 90 days
}

variable "ca_renew_before" {
  description = "Renew CA certificate before expiry (in hours)"
  type        = string
  default     = "720h0m0s" # 30 days
}
