# Create Azure Blob Storage containers for Mimir
resource "azurerm_storage_container" "mimir_blocks" {
  name                  = "mimir-blocks"
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
}

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

locals {
  mimir_values = templatefile("${path.module}/mimir-values.yaml.tpl", {
    storage_account_name         = var.storage_account_name
    mimir_blocks_container       = azurerm_storage_container.mimir_blocks.name
    mimir_alertmanager_container = azurerm_storage_container.mimir_alertmanager.name
    mimir_ruler_container        = azurerm_storage_container.mimir_ruler.name
    workload_identity_client_id  = var.workload_identity_client_id
    service_account_name         = var.service_account_name
  })
}

# Deploy Mimir using Helm
resource "helm_release" "mimir" {
  name       = "mimir"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "mimir-distributed"
  namespace  = var.namespace
  version    = "5.8.0" # Specify version for consistency

  values = [
    local.mimir_values
  ]

  depends_on = [
    azurerm_storage_container.mimir_blocks,
    azurerm_storage_container.mimir_alertmanager,
    azurerm_storage_container.mimir_ruler
  ]
}

# Get Mimir distributor service
data "kubernetes_service" "mimir_distributor" {
  metadata {
    name      = "${helm_release.mimir.name}-distributor"
    namespace = var.namespace
  }

  depends_on = [helm_release.mimir]
}
