output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.observability.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "aks_oidc_issuer_url" {
  description = "OIDC issuer URL for the AKS cluster"
  value       = module.aks.oidc_issuer_url
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.storage.storage_account_name
}

output "app_application_id" {
  description = "Application ID of the Azure AD app"
  value       = module.workload_identity.app_application_id
}

output "kube_config_command" {
  description = "Command to get AKS credentials"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.observability.name} --name ${module.aks.cluster_name}"
}

output "loki_gateway_ip" {
  description = "External IP of Loki gateway (may take a few minutes to provision)"
  value       = module.loki.gateway_external_ip
}

# Add the missing Loki authentication outputs
output "loki_username" {
  description = "Username for Loki basic auth"
  value       = module.loki.loki_username
  sensitive   = true
}

output "loki_password" {
  description = "Password for Loki basic auth"
  value       = module.loki.loki_password
  sensitive   = true
}

# OpenTelemetry Collector outputs
output "otel_collector_service" {
  description = "OpenTelemetry Collector service name"
  value       = module.otel_collector.service_name
}

# Mimir outputs
output "mimir_distributor_service" {
  description = "Mimir distributor service name"
  value       = module.mimir.distributor_service_name
}

output "mimir_blocks_container" {
  description = "Mimir blocks storage container"
  value       = module.mimir.blocks_container_name
}

# Tempo outputs
output "tempo_distributor_service" {
  description = "Tempo distributor service name"
  value       = module.tempo.distributor_service_name
}

output "tempo_traces_container" {
  description = "Tempo traces storage container"
  value       = module.tempo.traces_container_name
}
