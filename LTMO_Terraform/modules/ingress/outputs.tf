output "ingress_name" {
  description = "Name of the ingress resource"
  value       = kubernetes_ingress_v1.observability.metadata[0].name
}

output "ingress_namespace" {
  description = "Namespace of the ingress resource"
  value       = kubernetes_ingress_v1.observability.metadata[0].namespace
}

output "ingress_class_name" {
  description = "IngressClass name used by the ingress"
  value       = kubernetes_ingress_v1.observability.spec[0].ingress_class_name
}

output "ingress_ip" {
  description = "LoadBalancer IP address of the ingress controller"
  value = var.install_nginx_controller ? (
    length(data.kubernetes_service.nginx_ingress_controller) > 0 ?
    try(data.kubernetes_service.nginx_ingress_controller[0].status[0].load_balancer[0].ingress[0].ip, "Pending") :
    "Not managed by this module"
  ) : "Not managed by this module - check your existing ingress controller service"
}

output "ingress_host" {
  description = "Hostname configured for the ingress (if any)"
  value       = var.host != "" ? var.host : "IP-based access"
}

output "loki_endpoint" {
  description = "URL path for accessing Loki"
  value       = "/loki"
}

output "mimir_endpoint" {
  description = "URL path for accessing Mimir"
  value       = "/mimir"
}

output "tempo_endpoint" {
  description = "URL path for accessing Tempo"
  value       = "/tempo"
}

output "nginx_controller_installed" {
  description = "Whether NGINX Ingress Controller was installed by this module"
  value       = var.install_nginx_controller
}
