resource "google_service_account" "svcacct" {
  account_id = "tf-svc-${var.name}"
}

resource "google_service_account_key" "svcacct" {
  service_account_id = google_service_account.svcacct.name

  depends_on = [null_resource.after-pause]
}

resource "google_project_iam_member" "svcacct-role-viewer" {
  role   = "roles/container.viewer"
  member = "serviceAccount:${google_service_account.svcacct.email}"

  depends_on = [null_resource.after-pause]
}

resource "google_project_iam_member" "svcacct-role-secrets" {
  role   = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.svcacct.email}"

  depends_on = [null_resource.after-pause]
}

resource "kubernetes_namespace" "k8s-ns" {
  metadata {
    name = var.name
  }
}

resource "kubernetes_role_binding" "k8s-role-binding" {
  metadata {
    namespace = var.name
    name      = "edit-${var.name}"
  }

  subject {
    kind      = "User"
    name      = google_service_account.svcacct.email
    namespace = var.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "edit" // from GKE
  }
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
