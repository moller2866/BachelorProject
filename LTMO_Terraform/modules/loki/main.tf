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

locals {
  loki_values = templatefile("${path.module}/loki-values.yaml.tpl", {
    storage_account_name        = var.storage_account_name
    loki_chunk_container        = azurerm_storage_container.loki_chunks.name
    loki_ruler_container        = azurerm_storage_container.loki_ruler.name
    service_account_name        = var.service_account_name
    workload_identity_client_id = var.workload_identity_client_id
  })
}

# Add Grafana Helm repository
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = var.namespace
  version    = "6.42.0" # Specify version for consistency

  values = [
    local.loki_values
  ]

  depends_on = [
    azurerm_storage_container.loki_chunks,
    azurerm_storage_container.loki_ruler
  ]
}

# Get Loki gateway service to output external IP
data "kubernetes_service" "loki_gateway" {
  metadata {
    name      = "${helm_release.loki.name}-gateway"
    namespace = var.namespace
  }

  depends_on = [helm_release.loki]
}
