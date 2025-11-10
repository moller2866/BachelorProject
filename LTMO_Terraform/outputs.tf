output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.observability.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "aks_oidc_issuer_url" {
  description = "OIDC issuer URL for the AKS cluster"
  value       = module.aks.oidc_issuer_url
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.storage.storage_account_name
}

output "app_application_id" {
  description = "Application ID of the Azure AD app"
  value       = module.workload_identity.app_application_id
}

output "kube_config_command" {
  description = "Command to get AKS credentials"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.observability.name} --name ${module.aks.cluster_name}"
}

output "loki_gateway_ip" {
  description = "External IP of Loki gateway (may take a few minutes to provision)"
  value       = module.loki.gateway_external_ip
}

# Add the missing Loki authentication outputs
output "loki_username" {
  description = "Username for Loki basic auth"
  value       = module.loki.loki_username
  sensitive   = true
}

output "loki_password" {
  description = "Password for Loki basic auth"
  value       = module.loki.loki_password
  sensitive   = true
}

# OpenTelemetry Collector outputs
output "otel_collector_service" {
  description = "OpenTelemetry Collector service name"
  value       = module.otel_collector.service_name
}

# Mimir outputs
output "mimir_distributor_service" {
  description = "Mimir distributor service name"
  value       = module.mimir.distributor_service_name
}

output "mimir_blocks_container" {
  description = "Mimir blocks storage container"
  value       = module.mimir.blocks_container_name
}

# Tempo outputs
output "tempo_distributor_service" {
  description = "Tempo distributor service name"
  value       = module.tempo.distributor_service_name
}

output "tempo_traces_container" {
  description = "Tempo traces storage container"
  value       = module.tempo.traces_container_name
}

# Unified Ingress outputs
output "ingress_ip" {
  description = "LoadBalancer IP address for the unified observability ingress"
  value       = module.ingress.ingress_ip
}

output "ingress_host" {
  description = "Hostname configured for the ingress (if any)"
  value       = module.ingress.ingress_host
}

output "loki_url" {
  description = "URL to access Loki via the unified ingress"
  value       = module.ingress.ingress_host != "IP-based access" ? "http://${module.ingress.ingress_host}/loki" : "http://${module.ingress.ingress_ip}/loki"
}

output "mimir_url" {
  description = "URL to access Mimir (Prometheus-compatible) via the unified ingress"
  value       = module.ingress.ingress_host != "IP-based access" ? "http://${module.ingress.ingress_host}/mimir" : "http://${module.ingress.ingress_ip}/mimir"
}

output "tempo_url" {
  description = "URL to access Tempo via the unified ingress"
  value       = module.ingress.ingress_host != "IP-based access" ? "http://${module.ingress.ingress_host}/tempo" : "http://${module.ingress.ingress_ip}/tempo"
}

output "ingress_endpoints_summary" {
  description = "Summary of all unified ingress endpoints"
  value = {
    ingress_ip   = module.ingress.ingress_ip
    ingress_host = module.ingress.ingress_host
    loki_path    = "/loki"
    mimir_path   = "/mimir"
    tempo_path   = "/tempo"
  }
}

# cert-manager outputs
output "cert_manager_namespace" {
  description = "Namespace where cert-manager is installed"
  value       = module.cert_manager.namespace
}

output "cert_manager_version" {
  description = "Version of cert-manager deployed"
  value       = module.cert_manager.chart_version
}

output "cert_manager_status" {
  description = "Status of cert-manager deployment"
  value       = module.cert_manager.release_status
}

output "cert_manager_ca_issuer" {
  description = "Name of the CA ClusterIssuer for internal mTLS certificates"
  value       = module.cert_manager.ca_issuer_name
}

output "cert_manager_ca_secret" {
  description = "Name of the root CA certificate secret"
  value       = module.cert_manager.ca_secret_name
}

output "cert_manager_letsencrypt_issuer" {
  description = "Name of the Let's Encrypt ClusterIssuer (if enabled)"
  value       = module.cert_manager.letsencrypt_issuer_name
}

# Certificates outputs
output "grafana_client_cert_secret" {
  description = "Kubernetes secret containing Grafana's client certificate for mTLS"
  value       = module.certificates.grafana_client_cert_secret
}

output "developer_client_cert_secret" {
  description = "Kubernetes secret containing developer client certificate for CLI access"
  value       = module.certificates.developer_client_cert_secret
}

output "observability_ingress_tls_secret" {
  description = "Kubernetes secret containing TLS certificate for the unified observability ingress"
  value       = module.certificates.observability_ingress_tls_secret
}

output "observability_ingress_hostname" {
  description = "Hostname for the unified observability ingress"
  value       = module.certificates.ingress_hostname
}

output "grafana_url" {
  description = "URL to access Grafana frontend"
  value       = var.grafana_url != "" ? var.grafana_url : "http://grafana-umbraco-dev-dns.westeurope.azurecontainer.io:3000/"
}
