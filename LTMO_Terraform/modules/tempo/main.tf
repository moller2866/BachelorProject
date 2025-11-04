# Create Azure Blob Storage container for Tempo
resource "azurerm_storage_container" "tempo_traces" {
  name                  = "tempo-traces"
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
}

# Generate dynamic Helm values for Tempo
locals {
  tempo_values = templatefile("${path.module}/tempo-values.yaml.tpl", {
    storage_account_name        = var.storage_account_name
    tempo_traces_container      = azurerm_storage_container.tempo_traces.name
    workload_identity_client_id = var.workload_identity_client_id
    service_account_name        = var.service_account_name
  })
}

# Deploy Tempo using Helm - CHANGED to tempo-distributed
resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo-distributed"
  namespace  = var.namespace
  version    = "1.48.0" # Updated version for tempo-distributed

  values = [local.tempo_values]

  depends_on = [azurerm_storage_container.tempo_traces]
}

# Get Tempo distributor service
data "kubernetes_service" "tempo_distributor" {
  metadata {
    name      = "${helm_release.tempo.name}-distributor"
    namespace = var.namespace
  }

  depends_on = [helm_release.tempo]
}
