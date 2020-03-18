data "google_container_cluster" "primary" {
    name = var.cluster-name
    location = var.region
}

provider "kubernetes" {
  load_config_file = "false"

  host = "https://${data.google_container_cluster.primary.endpoint}"

  username = data.google_container_cluster.primary.master_auth.0.username
  password = data.google_container_cluster.primary.master_auth.0.password

  insecure = true
}


resource "kubernetes_service_account" "svcacct-tf-admin" {
  metadata {
    name = "svcacct-tf-admin"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "svcacct-tf-admin-crb" {
  metadata {
    name = "${kubernetes_service_account.svcacct-tf-admin.metadata.0.name}-crb"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.svcacct-tf-admin.metadata.0.name
    namespace = kubernetes_service_account.svcacct-tf-admin.metadata.0.namespace
  }
}

data "kubernetes_secret" "svcacct-tf-admin-secret" {
  metadata {
    name = kubernetes_service_account.svcacct-tf-admin.default_secret_name
    namespace = "kube-system"
  }
}

resource "google_secret_manager_secret" "svcacct-tf-admin-token" {
  provider = google-beta

  secret_id = "svcacct-tf-admin-token"

  labels = {
    type = "svcacct"
    svcacct = kubernetes_service_account.svcacct-tf-admin.metadata.0.name
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "svcacct-tf-admin-token-version" {
  provider = google-beta

  secret = google_secret_manager_secret.svcacct-tf-admin-token.id

  secret_data = base64decode(data.kubernetes_secret.svcacct-tf-admin-secret.data["token"])
}

resource "google_secret_manager_secret" "gke-endpoint" {
  provider = google-beta

  secret_id = "gke-endpoint"

  labels = {
    type = "endpoint"
    cluster = data.google_container_cluster.primary.name
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "gke-endpoint-version" {
  provider = google-beta

  secret = google_secret_manager_secret.gke-endpoint.id

  secret_data = "https://${data.google_container_cluster.primary.endpoint}"
}