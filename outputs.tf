output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP Region"
  value       = var.region
}

output "service_name" {
  description = "Name of Cloud Run service"
  value       = google_cloud_run_service.service.name
}

output "service_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_service.service.status[0].url
}

output "environment" {
  description = "Deployment environment"
  value       = var.environment
}

output "max_instances" {
  description = "Applied max instance count"
  value       = var.max_instances
}

output "current_image" {
  description = "Current container image"
  value       = data.google_cloud_run_service.existing.template[0].spec[0].containers[0].image
}

output "max_concurrency" {
  description = "Maximum concurrent requests per instance"
  value       = google_cloud_run_service.service.template[0].spec[0].container_concurrency
}
