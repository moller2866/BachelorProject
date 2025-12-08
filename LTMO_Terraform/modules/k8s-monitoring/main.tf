locals {
  k8s_monitoring_values = templatefile("${path.module}/k8s-monitoring-values.yaml.tpl", {
    namespace       = var.namespace
    cluster_name    = var.cluster_name
    scrape_interval = var.scrape_interval
    enable_events   = var.enable_cluster_events
    enable_pod_logs = var.enable_pod_logs
    enable_metrics  = var.enable_cluster_metrics
  })
}

# Install the k8s-monitoring Helm chart
resource "helm_release" "k8s_monitoring" {
  name       = "k8s-monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "k8s-monitoring"
  namespace  = var.namespace
  version    = "3.6.1"

  values = [local.k8s_monitoring_values]

  # Add timeout for larger deployments
  timeout = 600

  # Wait for resources to be ready
  wait = true
}
