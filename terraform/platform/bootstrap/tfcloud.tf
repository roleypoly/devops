locals {
  repo   = "roleypoly/devops"
  branch = "tf-redux"
}

module "tfcws-kubernetes" {
  source            = "github.com/roleypoly/devops.git//terraform/modules/tfc-workspace?ref=tf-redux"
  workspace-name    = "roleypoly-platform-kubernetes"
  repo              = local.repo
  branch            = local.branch
  directory         = "terraform/platform/kubernetes"
  auto_apply        = false
  dependent_modules = []
  tfc_org           = var.tfc_org
  tf_oauth_token_id = var.tfc_oauth_token_id

  secret-vars = {
    digitalocean_token = var.digitalocean_token
  }
}

module "tfcws-services" {
  source            = "github.com/roleypoly/devops.git//terraform/modules/tfc-workspace?ref=tf-redux"
  workspace-name    = "roleypoly-platform-services"
  repo              = local.repo
  branch            = local.branch
  directory         = "terraform/platform/services"
  auto_apply        = false
  dependent_modules = ["nginx-ingress-controller"]
  tfc_org           = var.tfc_org
  tf_oauth_token_id = var.tfc_oauth_token_id

  secret-vars = {
    vault_gcs_token = local.vaultGcsSvcacctKey
    vault_gcs_url   = local.vaultGcsUrl
  }

  vars = {
    gcp_region  = var.gcp_region
    gcp_project = var.gcp_project
  }
}

module "tfcws-app" {
  source            = "github.com/roleypoly/devops.git//terraform/modules/tfc-workspace?ref=tf-redux"
  workspace-name    = "roleypoly-platform-app"
  repo              = local.repo
  branch            = local.branch
  directory         = "terraform/platform/app"
  auto_apply        = false
  dependent_modules = ["tfc-workspace"]
  tfc_org           = var.tfc_org
  tf_oauth_token_id = var.tfc_oauth_token_id

  secret-vars = {
    vault_gcs_token = local.vaultGcsSvcacctKey
    vault_gcs_url   = local.vaultGcsUrl
  }

  vars = {
    gcp_region  = var.gcp_region
    gcp_project = var.gcp_project
  }
}