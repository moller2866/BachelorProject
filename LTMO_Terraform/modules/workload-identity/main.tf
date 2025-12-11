data "azuread_client_config" "current" {}

# Create Azure AD Application
resource "azuread_application" "observability" {
  display_name = var.app_display_name
  owners       = [data.azuread_client_config.current.object_id]
}

# Create Service Principal
resource "azuread_service_principal" "observability" {
  client_id = azuread_application.observability.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

# Create Federated Identity Credential for Kubernetes Service Account
resource "azuread_application_federated_identity_credential" "observability_loki" {
  application_id = azuread_application.observability.id
  display_name   = "${var.app_display_name}-k8s-federated"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = var.aks_oidc_issuer_url
  subject        = "system:serviceaccount:${var.loki_namespace}:${var.service_account_name_loki}"
}
resource "azuread_application_federated_identity_credential" "observability_mimir" {
  application_id = azuread_application.observability.id
  display_name   = "${var.app_display_name}-k8s-federated-mimir"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = var.aks_oidc_issuer_url
  subject        = "system:serviceaccount:${var.mimir_namespace}:${var.service_account_name_mimir}"
}
resource "azuread_application_federated_identity_credential" "observability_tempo" {
  application_id = azuread_application.observability.id
  display_name   = "${var.app_display_name}-k8s-federated-tempo"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = var.aks_oidc_issuer_url
  subject        = "system:serviceaccount:${var.tempo_namespace}:${var.service_account_name_tempo}"
}

# Assign Storage Blob Data Contributor role
resource "azurerm_role_assignment" "storage_blob_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.observability.object_id
}
