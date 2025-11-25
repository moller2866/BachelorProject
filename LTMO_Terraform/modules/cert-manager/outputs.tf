output "namespace" {
  description = "The namespace where cert-manager is installed"
  value       = var.namespace
}

output "release_name" {
  description = "The name of the Helm release"
  value       = helm_release.cert_manager.name
}

output "release_status" {
  description = "The status of the Helm release"
  value       = helm_release.cert_manager.status
}

output "chart_version" {
  description = "The version of the cert-manager chart deployed"
  value       = helm_release.cert_manager.version
}

output "ca_issuer_name" {
  description = "Name of the CA ClusterIssuer for internal certificates"
  value       = kubernetes_manifest.ca_issuer.manifest.metadata.name
}

output "ca_secret_name" {
  description = "Name of the Kubernetes secret containing the root CA certificate"
  value       = kubernetes_manifest.root_ca_certificate.manifest.spec.secretName
}

output "letsencrypt_issuer_name" {
  description = "Name of the Let's Encrypt ClusterIssuer (if enabled)"
  value       = var.enable_letsencrypt && var.letsencrypt_email != "" ? kubernetes_manifest.letsencrypt_issuer[0].manifest.metadata.name : null
}
