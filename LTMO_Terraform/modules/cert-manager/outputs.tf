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

output "ready" {
  description = "Indicates that cert-manager is ready to use"
  value       = time_sleep.wait_for_cert_manager.id != null
}
