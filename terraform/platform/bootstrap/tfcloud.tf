locals {
    repo = "roleypoly/devops"
    branch = "tf-redux"
}

module "tfc-platform-workspaces" {
    source = "github.com/roleypoly/devops.git//terraform/modules/tfc-workspace?ref=tf-redux"

    for_each {
        app = {
            dependent_modules = [
                "tfc-workspace"
            ],
        }

        kubernetes = {
            dependent_modules = [],
            secret-vars = {
                digitalocean_token = var.digitalocean_token
            },
        }

        services = {
            dependent_modules = [
                "nginx-ingress-controller"
            ],
            secret-vars = {
                vault_gcs_token = local.vaultGcsSvcacctKey
                vault_gcs_url   = local.vaultGcsUrl
            },
            vars = {
                gcp_region  = var.gcp_region
                gcp_project = var.gcp_project
            },
        }
    }

    workspace-name    = "roleypoly-platform-${each.key}"
    repo              = local.repo
    branch            = local.branch
    directory         = "terraform/platform/${each.key}"
    auto_apply        = false
    dependent_modules = each.value.dependent_modules
}