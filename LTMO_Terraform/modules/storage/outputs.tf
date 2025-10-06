output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.loki.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.loki.name
}

output "loki_chunk_container_name" {
  description = "Name of the Loki chunks container"
  value       = azurerm_storage_container.loki_chunks.name
}

output "loki_ruler_container_name" {
  description = "Name of the Loki ruler container"
  value       = azurerm_storage_container.loki_ruler.name
}
