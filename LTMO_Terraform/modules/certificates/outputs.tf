output "grafana_client_cert_secret" {
  description = "Name of the Kubernetes secret containing Grafana's client certificate"
  value       = kubernetes_manifest.grafana_client_cert.manifest.spec.secretName
}

output "ingress_hostname" {
  description = "Hostname for the unified observability ingress"
  value       = var.enable_ingress_tls && var.base_domain != "" ? (var.ingress_hostname != "" ? var.ingress_hostname : "observability-${var.region_name}.${var.base_domain}") : null
}

output "certificates_ready" {
  description = "All certificates have been created"
  value       = true
  depends_on = [
    kubernetes_manifest.grafana_client_cert
  ]
}
