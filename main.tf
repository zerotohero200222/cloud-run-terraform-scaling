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

data "google_cloud_run_service" "existing" {
  name     = var.service_name
  location = var.region
}

resource "google_cloud_run_service" "scaling_update" {
  name     = var.service_name
  location = var.region

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = tostring(var.max_instances)
      }
    }

    spec {
      containers {
        image = data.google_cloud_run_service.existing.template[0].spec[0].containers[0].image
      }
    }
  }

  autogenerate_revision_name = true

  traffic {
    latest_revision = true
    percent         = 100
  }

  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,
      template[0].metadata[0].annotations,
      template[0].spec[0].containers[0].env,
    ]
  }
}





