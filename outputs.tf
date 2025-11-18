output "service_name" {
  description = "Name of Cloud Run service"
  value       = data.google_cloud_run_service.existing.name
}

output "service_url" {
  description = "URL of Cloud Run service"
  value       = data.google_cloud_run_service.existing.status[0].url
}

output "max_instances" {
  description = "Updated max instance count"
  value       = var.max_instances
}
