variable "namespace" {
  description = "The namespace where monitoring components are deployed"
  type        = string
  default     = "observability"
}

variable "cluster_name" {
  description = "Name of the cluster for telemetry labels"
  type        = string
  default     = "lgtm-cluster"
}

variable "scrape_interval" {
  description = "Global scrape interval for metrics collection"
  type        = string
  default     = "15s"
}

variable "enable_cluster_events" {
  description = "Enable collection of Kubernetes cluster events"
  type        = bool
  default     = true
}

variable "enable_pod_logs" {
  description = "Enable collection of pod logs"
  type        = bool
  default     = true
}

variable "enable_cluster_metrics" {
  description = "Enable collection of cluster metrics"
  type        = bool
  default     = true
}
