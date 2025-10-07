output "service_name" {
  description = "Name of the OpenTelemetry Collector service"
  value       = data.kubernetes_service.otel_collector.metadata[0].name
}

output "cluster_ip" {
  description = "Cluster IP of the OpenTelemetry Collector service"
  value       = data.kubernetes_service.otel_collector.spec[0].cluster_ip
}
