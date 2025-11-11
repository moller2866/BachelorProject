
locals {
  cert_manager_values = templatefile("${path.module}/cert-manager-values.yaml.tpl", {
    install_crds              = var.install_crds
    replica_count             = var.replica_count
    webhook_replica_count     = var.webhook_replica_count
    cainjector_replica_count  = var.cainjector_replica_count
    enable_prometheus_metrics = var.enable_prometheus_metrics
  })
}

# Install cert-manager using Helm
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = var.namespace
  version    = var.chart_version

  # Wait for all resources to be ready
  wait          = true
  wait_for_jobs = true
  timeout       = 600

  values = [
    local.cert_manager_values
  ]
}

# Wait for cert-manager to be ready
resource "time_sleep" "wait_for_cert_manager" {
  depends_on = [helm_release.cert_manager]

  create_duration = "45s"
}
