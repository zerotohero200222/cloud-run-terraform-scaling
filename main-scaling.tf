# Read existing Cloud Run service
data "google_cloud_run_service" "existing" {
  name     = var.service_name
  location = var.region
}

# Apply only scaling changes
resource "google_cloud_run_service" "scaling_update" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  autogenerate_revision_name = true

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
      container_concurrency = data.google_cloud_run_service.existing.template[0].spec[0].container_concurrency
      timeout_seconds       = data.google_cloud_run_service.existing.template[0].spec[0].timeout_seconds
      service_account_name  = data.google_cloud_run_service.existing.template[0].spec[0].service_account_name

      containers {
        # Preserve existing image
        image = data.google_cloud_run_service.existing.template[0].spec[0].containers[0].image

        # Preserve existing env vars
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

  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,
      template[0].spec[0].containers[0].env,
      metadata[0].annotations,
    ]
  }
}
