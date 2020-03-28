data "google_container_cluster" "primary" {
  name     = var.cluster-name
  location = var.region
}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${data.google_container_cluster.primary.endpoint}"
  token = var.svcacct-token

  cluster_ca_certificate = base64decode(
    data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate,
  )
}

module "roleypoly-prd" {
  source = "./service-namespace"

  name             = "roleypoly-prd"
  tf-git-repo      = "roleypoly/devops"
  tf-git-repo-path = "terraform"
  tf-oauth-id      = var.tf-oauth-id

  svcacct-email = var.svcacct-email
  svcacct-token = var.svcacct-token
  cluster-name  = var.cluster-name
  region        = var.region
}

module "roleypoly-stg" {
  source = "./service-namespace"

  name             = "roleypoly-stg"
  tf-git-repo      = "roleypoly/devops"
  tf-git-repo-path = "terraform"
  tf-auto-apply    = true
  tf-oauth-id      = var.tf-oauth-id

  svcacct-email = var.svcacct-email
  svcacct-token = var.svcacct-token
  cluster-name  = var.cluster-name
  region        = var.region
}

module "nginx-ingress" {
  source = "./ingress"
}

module "dns" {
  source = "./dns"

  ingress-name       = module.nginx-ingress.service-name
  ingress-namespace  = module.nginx-ingress.service-namespace
  ingress-endpoint   = module.nginx-ingress.service-endpoint
  cloudflare-zone-id = var.cloudflare-zone-id
  record-name        = "${var.cluster-name}.kc"
}
