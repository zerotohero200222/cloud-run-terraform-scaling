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

############################################
# Cloud Run v2 – Manage ONLY max instances
############################################

resource "google_cloud_run_v2_service" "scaling" {
  project  = var.project_id
  name     = var.service_name
  location = var.region

  template {
    containers {
      # Use the SAME image your Cloud Run service actually runs
      # Replace if needed
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }

    # Only max instance scaling (as you requested)
    scaling {
      max_instance_count = var.max_instances
    }
  }
}



