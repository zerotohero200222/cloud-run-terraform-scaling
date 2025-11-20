variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "service_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "max_instances" {
  type = number
}

variable "max_instance_request_concurrency" {
  type    = number
  default = null
}

