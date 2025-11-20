provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_cloud_run_service" "existing" {
  name     = var.service_name
  location = var.region
}

resource "google_cloud_run_service" "service" {
  name     = var.service_name
  location = var.region

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = tostring(var.max_instances)

        "autoscaling.knative.dev/minScale" = try(
          data.google_cloud_run_service.existing.template[0].metadata[0].annotations["autoscaling.knative.dev/minScale"],
          "0"
        )

        "run.googleapis.com/cpu-throttling" = try(
          data.google_cloud_run_service.existing.template[0].metadata[0].annotations["run.googleapis.com/cpu-throttling"],
          "true"
        )
      }
    }

    spec {
      container_concurrency = var.max_instance_request_concurrency

      containers {
        image = data.google_cloud_run_service.existing.template[0].spec[0].containers[0].image
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}







