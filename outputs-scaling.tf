output "service_name" {
  description = "The name of the Cloud Run service"
  value       = google_cloud_run_service.scaling_update.name
}

output "current_min_instances" {
  description = "Current minimum instances configuration"
  value       = var.min_instances
}

output "current_max_instances" {
  description = "Current maximum instances configuration"
  value       = var.max_instances
}

output "max_concurrency" {
  description = "Maximum concurrent requests per instance"
  value       = var.max_instance_request_concurrency
}

output "service_url" {
  description = "The public URL of the Cloud Run service"
  value       = google_cloud_run_service.scaling_update.status[0].url
}
