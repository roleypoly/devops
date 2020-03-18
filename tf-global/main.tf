provider "google" {
  project     = var.google-cloud-project
  region      = var.google-cloud-region
  credentials = var.google-cloud-svcacct
}

provider "google-beta" {
  project     = var.google-cloud-project
  region      = var.google-cloud-region
  credentials = var.google-cloud-svcacct
}

module "gke-cluster-init" {
  source = "./gke-cluster-init"

  region = var.google-cloud-region-az
}

module "gke-cluster-bootstrap" {
  source = "./gke-cluster-bootstrap"

  region       = var.google-cloud-region-az
  cluster-name = module.gke-cluster-init.cluster-name
}
