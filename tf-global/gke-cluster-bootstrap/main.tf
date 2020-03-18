data "google_container_cluster" "primary" {
    name = var.cluster-name
    location = var.region
}

provider "kubernetes" {
  load_config_file = false

  host = "https://${data.google_container_cluster.primary.endpoint}"
  token = var.svcacct-token

  cluster_ca_certificate = base64decode(
    data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate,
  )
}

module "roleypoly-prd" {
  source = "./service-namespace"

  name = "roleypoly-prd"
}

module "roleypoly-stg" {
  source = "./service-namespace"

  name = "roleypoly-stg"
}

module "medkit" {
  source = "./service-namespace"

  name = "medkit"
}

module "midori" {
  source = "./service-namespace"

  name = "midori"
}