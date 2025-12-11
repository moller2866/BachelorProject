output "ingress_ip" {
  description = "LoadBalancer IP address of the ingress controller"
  value       = try(data.kubernetes_service.nginx_ingress_controller.status[0].load_balancer[0].ingress[0].ip, "Pending")
}

output "ingress_hostname_nip_io" {
  description = "nip.io hostname based on the LoadBalancer IP"
  value       = try("${data.kubernetes_service.nginx_ingress_controller.status[0].load_balancer[0].ingress[0].ip}.nip.io", "pending.nip.io")
}

output "ingress_class_name" {
  description = "Name of the IngressClass"
  value       = var.ingress_class_name
}

output "controller_service_name" {
  description = "Name of the NGINX controller service"
  value       = "ingress-nginx-controller"
}
