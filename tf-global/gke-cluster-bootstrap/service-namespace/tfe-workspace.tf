resource "tfe_workspace" "tfc-ws" {
  name              = var.name
  organization      = "Roleypoly"
  auto_apply        = var.tf-auto-apply
  working_directory = var.tf-git-repo-path
  trigger_prefixes  = [var.tf-git-repo-path]

  vcs_repo {
    identifier     = var.tf-git-repo
    oauth_token_id = var.tf-oauth-id
  }
}

resource "tfe_variable" "tfc-var-region" {
  key          = "google-cloud-region"
  value        = var.region
  workspace_id = tfe_workspace.tfc-ws.id
  category     = "terraform"
}

resource "tfe_variable" "tfc-var-cluster-name" {
  key          = "google-cloud-cluster-name"
  value        = var.cluster-name
  workspace_id = tfe_workspace.tfc-ws.id
  category     = "terraform"
}

resource "tfe_variable" "tfc-var-svcacct" {
  key          = "google-cloud-svcacct"
  value        = google_service_account_key.svcacct.private_key
  workspace_id = tfe_workspace.tfc-ws.id
  category     = "terraform"
  sensitive    = true
}

resource "tfe_variable" "tfc-var-project" {
  key          = "google-cloud-project"
  value        = google_service_account.svcacct.project
  workspace_id = tfe_workspace.tfc-ws.id
  category     = "terraform"
  sensitive    = true
}

resource "tfe_variable" "tfc-var-wsname" {
  key          = "google-cloud-project"
  value        = var.name
  workspace_id = tfe_workspace.tfc-ws.id
  category     = "terraform"
  sensitive    = true
}
