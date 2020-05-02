locals {
  repo   = "roleypoly/devops"
  branch = "master"
  tfc_org = "Roleypoly"
}

module "tfcws-kubernetes" {
  source             = "github.com/roleypoly/devops.git//terraform/modules/tfc-workspace?ref=tf-redux"
  workspace-name     = "roleypoly-platform-kubernetes"
  repo               = local.repo
  branch             = local.branch
  tfc_webhook_url    = var.tfc_webhook_url
  directory          = "terraform/platform/kubernetes"
  auto_apply         = false
  dependent_modules  = []
  tfc_org            = local.tfc_org
  tfc_oauth_token_id = var.tfc_oauth_token_id

  secret-vars = {
    digitalocean_token = var.digitalocean_token
  }
}

module "tfcws-services" {
  source             = "github.com/roleypoly/devops.git//terraform/modules/tfc-workspace?ref=tf-redux"
  workspace-name     = "roleypoly-platform-services"
  repo               = local.repo
  branch             = local.branch
  tfc_webhook_url    = var.tfc_webhook_url
  directory          = "terraform/platform/services"
  auto_apply         = false
  dependent_modules  = ["nginx-ingress-controller"]
  tfc_org            = local.tfc_org
  tfc_oauth_token_id = var.tfc_oauth_token_id

  secret-vars = {
    vault_gcs_token = local.vaultGcsSvcacctKey
    vault_gcs_url   = local.vaultGcsUrl
  }

  vars = {
    gcp_region  = var.gcs_region
    gcp_project = var.gcs_project
  }
}

module "tfcws-app" {
  source             = "github.com/roleypoly/devops.git//terraform/modules/tfc-workspace?ref=tf-redux"
  workspace-name     = "roleypoly-platform-app"
  repo               = local.repo
  branch             = local.branch
  tfc_webhook_url    = var.tfc_webhook_url
  directory          = "terraform/platform/app"
  auto_apply         = false
  dependent_modules  = ["tfc-workspace"]
  tfc_org            = local.tfc_org
  tfc_oauth_token_id = var.tfc_oauth_token_id
}