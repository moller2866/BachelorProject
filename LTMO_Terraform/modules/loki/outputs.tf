output "release_name" {
  description = "Name of the Helm release"
  value       = helm_release.loki.name
}
