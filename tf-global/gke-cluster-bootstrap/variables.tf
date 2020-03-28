variable "region" {
  type    = string
  default = "us-east1-d"
}

variable "cluster-name" {
  type        = string
  description = "GKE Cluster Name"
}

variable "svcacct-email" {
  type = string
}

variable "svcacct-token" {
  type = string
}

variable "tf-oauth-id" {
  type = string
}

variable "cloudflare-api-token" {
  type = string
}

variable "cloudflare-zone-id" {
  type = string
}
