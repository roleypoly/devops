resource "google_container_cluster" "primary" {
  location = "us-east1-a"

  remove_default_node_pool = true
  initial_node_count       = 1
}

output "cluster_name" {
  value = "${google_container_cluster.primary.name}"
}

resource "google_container_node_pool" "primary_static_nodes" {
  location   = "us-east1-a"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "n1-standard-1"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  location   = "us-east1-a"
  cluster    = "${google_container_cluster.primary.name}"
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

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}


// Set Cluster Secrets
resource "google_secret_manager_secret" "gke-cert-pem" {
  provider = "google-beta"

  secret_id = "${google_container_cluster.primary.name}-cert-pem"

  labels = {
    type = "k8s-client-certificate"
    which = "pem"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "gke-cert-pem-version" {
  provider = "google-beta"

  secret = "${google_secret_manager_secret.secret-basic.id}"

  secret_data = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

resource "google_secret_manager_secret" "gke-cert-key" {
  provider = "google-beta"

  secret_id = "${google_container_cluster.primary.name}-cert-key"

  labels = {
    type = "k8s-client-certificate"
    which = "key"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "gke-cert-ca-version" {
  provider = "google-beta"

  secret = "${google_secret_manager_secret.secret-basic.id}"

  secret_data = "${google_container_cluster.primary.master_auth.0.client_ca}"
}

resource "google_secret_manager_secret" "gke-cert-ca" {
  provider = "google-beta"

  secret_id = "${google_container_cluster.primary.name}-cert-ca"

  labels = {
    type = "k8s-client-certificate"
    which = "ca"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "gke-cert-ca-version" {
  provider = "google-beta"

  secret = "${google_secret_manager_secret.secret-basic.id}"

  secret_data = "${google_container_cluster.primary.master_auth.0.cluster_ca_cert}"
}