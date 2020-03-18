resource "google_service_account" "svcacct" {
  account_id = "tf-svc-${var.name}"
}

resource "google_service_account_key" "svcacct" {
  service_account_id = google_service_account.svcacct.name

  depends_on = [null_resource.after-pause]
}

resource "google_service_account_iam_binding" "svcacct-role-viewer" {
  role               = "roles/container.viewer"
  service_account_id = google_service_account_key.svcacct.service_account_id
  members            = []
}

resource "google_service_account_iam_binding" "svcacct-role-secret" {
  role               = "roles/secretmanager.secretAccessor"
  service_account_id = google_service_account_key.svcacct.service_account_id
  members            = []
}

resource "kubernetes_namespace" "k8s-ns" {
  metadata {
    name = var.name
  }
}

resource "kubernetes_role" "k8s-role" {
  metadata {
    namespace     = var.name
    generate_name = var.name
  }

  rule {
    api_groups = ["", "extensions", "apps"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "k8s-role-binding" {
  metadata {
    namespace = var.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = google_service_account.svcacct.email
    namespace = var.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.k8s-role.metadata.0.name
  }
}

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

// pause for eventual consistency
resource "null_resource" "before-pause" {
  depends_on = [google_service_account.svcacct]
}

resource "null_resource" "pause" {
  provisioner "local-exec" {
    command = "sleep 10"
  }

  triggers = {
    before = null_resource.before-pause.id
  }
}

resource "null_resource" "after-pause" {
  depends_on = [null_resource.pause]
}
