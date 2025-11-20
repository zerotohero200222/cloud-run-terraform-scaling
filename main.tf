terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Fetch the existing Cloud Run service to get current configuration
data "google_cloud_run_service" "existing" {
  name     = var.service_name
  location = var.region
}

# Update the existing Cloud Run service (not create new)
resource "google_cloud_run_service" "service" {
  name     = var.service_name
  location = var.region

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = tostring(var.max_instances)
        # Preserve minimum instances if set
        "autoscaling.knative.dev/minScale" = try(
          data.google_cloud_run_service.existing.template[0].metadata[0].annotations["autoscaling.knative.dev/minScale"],
          "0"
        )
        # Preserve other scaling annotations
        "run.googleapis.com/cpu-throttling" = try(
          data.google_cloud_run_service.existing.template[0].metadata[0].annotations["run.googleapis.com/cpu-throttling"],
          "true"
        )
      }
    }

    spec {
      # Preserve container concurrency if set
      container_concurrency = try(
        var.max_instance_request_concurrency != null ? var.max_instance_request_concurrency : data.google_cloud_run_service.existing.template[0].spec[0].container_concurrency,
        80
      )

      containers {
        # Use the current image from the existing service
        image = data.google_cloud_run_service.existing.template[0].spec[0].containers[0].image
        
        # Preserve environment variables if they exist
        dynamic "env" {
          for_each = try(data.google_cloud_run_service.existing.template[0].spec[0].containers[0].env, [])
          content {
            name  = env.value.name
            value = env.value.value
          }
        }
        
        # Preserve resource limits if they exist
        dynamic "resources" {
          for_each = length(try(data.google_cloud_run_service.existing.template[0].spec[0].containers[0].resources, [])) > 0 ? [1] : []
          content {
            limits = try(
              data.google_cloud_run_service.existing.template[0].spec[0].containers[0].resources[0].limits,
              {
                "cpu"    = "1000m"
                "memory" = "512Mi"
              }
            )
          }
        }
        
        # Preserve ports if they exist
        dynamic "ports" {
          for_each = try(data.google_cloud_run_service.existing.template[0].spec[0].containers[0].ports, [])
          content {
            name           = try(ports.value.name, null)
            container_port = ports.value.container_port
            protocol       = try(ports.value.protocol, null)
          }
        }
      }
      
      # Preserve service account
      service_account_name = try(
        data.google_cloud_run_service.existing.template[0].spec[0].service_account_name,
        null
      )
      
      # Preserve timeout
      timeout_seconds = try(
        data.google_cloud_run_service.existing.template[0].spec[0].timeout_seconds,
        300
      )
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true

  lifecycle {
    # Don't recreate service if only image or revision name changes
    ignore_changes = [
      template[0].spec[0].containers[0].image,
      template[0].metadata[0].name,
      metadata[0].annotations["run.googleapis.com/operation-id"],
      metadata[0].annotations["serving.knative.dev/creator"],
      metadata[0].annotations["serving.knative.dev/lastModifier"],
      metadata[0].annotations["client.knative.dev/user-image"]
    ]
  }
}







