output "distributor_service_name" {
  description = "Name of the Mimir distributor service"
  value       = data.kubernetes_service.mimir_distributor.metadata[0].name
}

output "cluster_ip" {
  description = "Cluster IP of the Mimir distributor service"
  value       = data.kubernetes_service.mimir_distributor.spec[0].cluster_ip
}

output "blocks_container_name" {
  description = "Name of the Mimir blocks container"
  value       = azurerm_storage_container.mimir_blocks.name
}

output "release_name" {
  description = "Name of the Helm release"
  value       = helm_release.mimir.name
}
