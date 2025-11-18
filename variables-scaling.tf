variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for Cloud Run"
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "Cloud Run service name to update scaling"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, uat, prod)"
  type        = string
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "max_instance_request_concurrency" {
  description = "Maximum requests per instance"
  type        = number
  default     = 80
}
