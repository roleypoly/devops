variable "name" {
  type = string
}

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

variable "tf-git-repo" {
  type = string
}

variable "tf-git-repo-path" {
  type    = string
  default = "/"
}

variable "tf-auto-apply" {
  type    = bool
  default = false
}

variable "tf-oauth-id" {
  type = string
}
