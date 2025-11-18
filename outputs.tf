output "service_name" {
  value = var.service_name
}

output "max_instances" {
  value = var.max_instances
}

output "service_url" {
  value = data.google_cloud_run_v2_service.existing.uri
}
