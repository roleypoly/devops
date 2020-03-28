terraform {
  backend "remote" {
    organization = "Roleypoly"

    workspaces {
      name = "Roleypoly-Infra"
    }
  }
}

locals {
  googleScopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

provider "google" {
  project     = var.google-cloud-project
  region      = var.google-cloud-region
  credentials = var.google-cloud-svcacct

  scopes = local.googleScopes
}

provider "google-beta" {
  project     = var.google-cloud-project
  region      = var.google-cloud-region
  credentials = var.google-cloud-svcacct

  scopes = local.googleScopes
}

provider "cloudflare" {
  version              = "~> 2.0"
  api_token            = var.cloudflare-api-token
  api_user_service_key = var.cloudflare-ca-token
}

data "google_client_openid_userinfo" "userinfo" {}
data "google_client_config" "config" {}

locals {
  tfSvcacctEmail = data.google_client_openid_userinfo.userinfo.email
  tfSvcacctToken = data.google_client_config.config.access_token
}

module "gke-cluster-init" {
  source = "./gke-cluster-init"

  region = var.google-cloud-region-az
}

module "gke-cluster-bootstrap" {
  source = "./gke-cluster-bootstrap"

  region               = var.google-cloud-region-az
  cluster-name         = module.gke-cluster-init.cluster-name
  cloudflare-api-token = var.cloudflare-api-token
  cloudflare-zone-id   = var.cloudflare-zone-id
  tf-oauth-id          = var.tf-oauth-id
  svcacct-email        = local.tfSvcacctEmail
  svcacct-token        = local.tfSvcacctToken
}
