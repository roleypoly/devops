resource "google_container_cluster" "primary" {
  location = var.region

  name = "roleypoly-gke-${var.region}"

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_static_nodes" {
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "n1-standard-1"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      node_type = "static"
    }

    disk_size_gb = 20

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 0

  autoscaling {
    max_node_count = 5
    min_node_count = 0
  }

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      node_type = "dynamic"
    }

    disk_size_gb = 20

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

// also immediately create the cluster admin RBAC service account. we can't store the client certs, so this is the next best thing 
provider "kubernetes" {
  load_config_file = "false"

  host = google_container_cluster.primary.endpoint

  client_certificate = google_container_cluster.primary.master_auth.0.client_certificate
  client_key = google_container_cluster.primary.master_auth.0.client_key
  # cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate

  insecure = true // implicit trust is ok here.
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
    cluster = google_container_cluster.primary.name
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "gke-endpoint-version" {
  provider = google-beta

  secret = google_secret_manager_secret.gke-endpoint.id

  secret_data = google_container_cluster.primary.endpoint
}