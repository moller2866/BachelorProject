resource "azurerm_storage_account" "loki" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"

  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

resource "azurerm_storage_container" "loki_chunks" {
  name                  = "loki-chunk-bucket"
  storage_account_name  = azurerm_storage_account.loki.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "loki_ruler" {
  name                  = "loki-ruler-bucket"
  storage_account_name  = azurerm_storage_account.loki.name
  container_access_type = "private"
}
