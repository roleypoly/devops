variable "google-cloud-svcacct" {
  type        = string
  description = "GCP Service Account JSON payload."
}

variable "google-cloud-project" {
  type        = string
  description = "GCP Project"
}

variable "google-cloud-region" {
  type        = string
  description = "GCP region"
}

variable "google-cloud-region-az" {
  type        = string
  description = "GCP region AZ"
}

variable "tf-oauth-id" {
  type = string
}

variable "tf-token" {
  type = string
}

variable "cloudflare-api-token" {
  type = string
}

variable "cloudflare-ca-token" {
  type = string
}

variable "cloudflare-zone-id" {
  type = string
}
