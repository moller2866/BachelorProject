resource "azurerm_storage_account" "observability" {
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

# Loki.
resource "azurerm_storage_container" "loki_chunks" {
  name                  = "loki-chunk-bucket"
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
}

resource "azurerm_storage_container" "loki_ruler" {
  name                  = "loki-ruler-bucket"
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
}

# Mimir.
resource "azurerm_storage_container" "mimir_alertmanager" {
  name                  = "mimir-alertmanager"
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
}

resource "azurerm_storage_container" "mimir_ruler" {
  name                  = "mimir-ruler"
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
}

# Tempo.
resource "azurerm_storage_container" "tempo_traces" {
  name                  = "tempo-traces"
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
}