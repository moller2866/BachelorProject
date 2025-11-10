output "grafana_client_cert_secret" {
  description = "Name of the Kubernetes secret containing Grafana's client certificate"
  value       = kubernetes_manifest.grafana_client_cert.manifest.spec.secretName
}

output "developer_client_cert_secret" {
  description = "Name of the Kubernetes secret containing developer client certificate"
  value       = kubernetes_manifest.developer_client_cert.manifest.spec.secretName
}

output "observability_ingress_tls_secret" {
  description = "Name of the Kubernetes secret containing unified ingress TLS certificate"
  value       = var.enable_ingress_tls && var.base_domain != "" ? kubernetes_manifest.observability_ingress_cert[0].manifest.spec.secretName : null
}

output "ingress_hostname" {
  description = "Hostname for the unified observability ingress"
  value       = var.enable_ingress_tls && var.base_domain != "" ? (var.ingress_hostname != "" ? var.ingress_hostname : "observability-${var.region_name}.${var.base_domain}") : null
}

output "grafana_url" {
  description = "URL to access Grafana (passed through from configuration)"
  value       = var.grafana_url
}

output "certificates_ready" {
  description = "All certificates have been created"
  value       = true
  depends_on = [
    kubernetes_manifest.grafana_client_cert,
    kubernetes_manifest.developer_client_cert
  ]
}
