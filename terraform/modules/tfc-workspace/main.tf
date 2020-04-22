locals {
    dependentModulesPathed = formatlist("terraform/modules/%s", var.dependent_modules)
    variableDescription    = "Terraform-owned variable"
}

resource "tfe_workspace" "ws" {
    name              = var.workspace-name
    organization      = var.tfc_org
    auto_apply        = var.auto_apply
    trigger_prefixes  = concat([var.directory], local.dependentModulesPathed)
    working_directory = var.directory

    vcs_repo {
        identifier     = var.repo
        branch         = var.branch
        oauth_token_id = var.tfc_oauth_token_id
    }
}

resource "tfe_variable" "vars" {
    for_each = var.vars
    
    key          = each.key
    value        = each.value
    category     = "terraform"
    workspace_id = tfe_workspace.ws.id
    sensitive    = false
}

resource "tfe_variable" "sensitive" {
    for_each = var.secret-vars
    
    key          = each.key
    value        = each.value
    category     = "terraform"
    workspace_id = tfe_workspace.ws.id
    sensitive    = true
}