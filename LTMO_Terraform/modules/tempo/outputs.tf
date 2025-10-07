output "distributor_service_name" {
  description = "Name of the Tempo distributor service"
  value       = data.kubernetes_service.tempo_distributor.metadata[0].name
}

output "cluster_ip" {
  description = "Cluster IP of the Tempo distributor service"
  value       = data.kubernetes_service.tempo_distributor.spec[0].cluster_ip
}

output "traces_container_name" {
  description = "Name of the Tempo traces container"
  value       = azurerm_storage_container.tempo_traces.name
}
