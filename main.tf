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

############################################
# Cloud Run v2 – manage ONLY max instances
############################################

# NOTE: providers (google) and terraform { required_providers } 
# stay in your existing provider.tf / versions.tf if you still have them.
# This file only defines the Cloud Run service resource.

resource "google_cloud_run_v2_service" "scaling" {
  project  = var.project_id
  name     = var.service_name
  location = var.region

  # Allow Terraform to update the service config
  deletion_protection = false

  template {
    # We must specify at least one container image.
    # Use the SAME image as your existing Cloud Run service.
    # If your service currently uses a different image,
    # update the image below or make it a variable.
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }

    # 🔥 This is the only thing you care about:
    scaling {
      max_instance_count = var.max_instances
    }
  }
}

