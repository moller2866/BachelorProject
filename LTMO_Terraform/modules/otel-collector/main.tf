# Deploy OpenTelemetry Collector using existing Helm values file
resource "helm_release" "otel_collector" {
  name       = "otel-collector"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  namespace  = var.namespace
  version    = "0.136.0" # Specify version for consistency
  timeout    = 120

  values = [
    file(var.helm_values_file)
  ]
}

# Get OpenTelemetry Collector service
data "kubernetes_service" "otel_collector" {
  metadata {
    name      = "${helm_release.otel_collector.name}-opentelemetry-collector"
    namespace = var.namespace
  }

  depends_on = [helm_release.otel_collector]
}
