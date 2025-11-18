# Data source to get the existing Cloud Run service
data "google_cloud_run_service" "existing" {
  name     = var.service_name
  location = var.region
}

# Update only the scaling configuration
resource "google_cloud_run_service" "scaling_update" {
  name     = var.service_name
  location = var.region

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"      = tostring(var.min_instances)
        "autoscaling.knative.dev/maxScale"      = tostring(var.max_instances)
        "run.googleapis.com/cpu-throttling"     = "true"
        "run.googleapis.com/startup-cpu-boost"  = "false"
      }
    }

    spec {
      container_concurrency = var.max_instance_request_concurrency
      
      containers {
        # Preserve the existing image
        image = data.google_cloud_run_service.existing.template[0].spec[0].containers[0].image
        
        # Preserve existing environment variables
        dynamic "env" {
          for_each = data.google_cloud_run_service.existing.template[0].spec[0].containers[0].env
          content {
            name  = env.value.name
            value = env.value.value
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true

  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,  # Don't change the image
      template[0].spec[0].containers[0].env,    # Don't change env vars
      metadata[0].annotations,                   # Preserve other annotations
    ]
  }
}
