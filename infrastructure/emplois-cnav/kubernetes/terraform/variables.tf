variable "scw_region" {
  type        = string
  description = "Scaleway region for resources"
}

variable "scw_zone" {
  type        = string
  description = "Scaleway zone for resources"
}

variable "managed" {
  type        = string
  description = "Indicates the resource is managed by Terraform"
  default     = "Managed by Terraform"
}
