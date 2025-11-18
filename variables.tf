variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "region" {
  description = "Cloud Run region"
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
}

variable "max_instances" {
  description = "Max instance count"
  type        = number
}
