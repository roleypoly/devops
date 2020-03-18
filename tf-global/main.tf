provider "google" {
  project     = var.google-cloud-project
  region      = var.google-cloud-region
  credentials = var.google-cloud-svcacct

  scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

provider "google-beta" {
  project     = var.google-cloud-project
  region      = var.google-cloud-region
  credentials = var.google-cloud-svcacct

  scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

data "google_client_openid_userinfo" "userinfo" {}
data "google_client_config" "clientconfig" {}

locals {
  tfSvcacctEmail = data.google_client_openid_userinfo.userinfo.email
  tfSvcacctToken = data.google_client_config.clientconfig.access_token
}

module "gke-cluster-init" {
  source = "./gke-cluster-init"

  region = var.google-cloud-region-az
}

module "gke-cluster-bootstrap" {
  source = "./gke-cluster-bootstrap"

  region        = var.google-cloud-region-az
  cluster-name  = module.gke-cluster-init.cluster-name
  svcacct-email = local.tfSvcacctEmail
  svcacct-token = local.tfSvcacctToken
  tf-oauth-id   = var.tf-oauth-id
}
