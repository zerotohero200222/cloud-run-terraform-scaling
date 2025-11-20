variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for Cloud Run service"
  type        = string
}

variable "service_name" {
  description = "Name of the Cloud Run service to update"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, uat, prod)"
  type        = string
  default     = "dev"
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  validation {
    condition     = var.max_instances > 0 && var.max_instances <= 1000
    error_message = "max_instances must be between 1 and 1000"
  }
}

variable "max_instance_request_concurrency" {
  description = "Maximum concurrent requests per instance"
  type        = number
  default     = null
  validation {
    condition     = var.max_instance_request_concurrency == null || (var.max_instance_request_concurrency > 0 && var.max_instance_request_concurrency <= 1000)
    error_message = "max_instance_request_concurrency must be between 1 and 1000 or null"
  }
}

