output "gateway_external_ip" {
  description = "External IP of the Loki gateway"
  value       = try(data.kubernetes_service.loki_gateway.status[0].load_balancer[0].ingress[0].ip, "Pending...")
}

output "loki_username" {
  description = "Username for Loki basic auth"
  value       = local.loki_username
  sensitive   = true
}

output "loki_password" {
  description = "Password for Loki basic auth"
  value       = local.loki_password
  sensitive   = true
}

output "release_name" {
  description = "Name of the Helm release"
  value       = helm_release.loki.name
}
