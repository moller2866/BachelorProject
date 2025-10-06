output "app_application_id" {
  description = "Application ID of the Azure AD app"
  value       = azuread_application.observability.client_id
}

output "service_principal_id" {
  description = "Object ID of the service principal"
  value       = azuread_service_principal.observability.object_id
}
