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

# Read existing Cloud Run service
data "google_cloud_run_v2_service" "existing" {
  name     = var.service_name
  location = var.region
}

resource "google_cloud_run_v2_service" "scaling" {
  name     = var.service_name
  location = var.region

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = tostring(var.max_instances)
      }
    }

    containers {
      image = data.google_cloud_run_v2_service.existing.template[0].containers[0].image
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      template[0].metadata[0].annotations["client.knative.dev/user-image"],
      client
    ]
  }
}
