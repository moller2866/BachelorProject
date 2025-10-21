output "grafana_fqdn" {
  description = "The public FQDN to access Grafana"
  value       = azurerm_container_group.grafana.fqdn
}

output "grafana_password" {
  description = "Admin password for Grafana"
  value       = var.grafana_password
  sensitive   = true
}

output "grafana_user" {
  description = "Admin password for Grafana"
  value       = var.grafana_user
  sensitive   = true
}