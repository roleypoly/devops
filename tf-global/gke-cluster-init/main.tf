resource "google_container_cluster" "primary" {
  location = var.region

  name = "roleypoly-gke-${var.region}"

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_static_nodes" {
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 2

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

resource "google_secret_manager_secret" "gke-endpoint" {
  provider = google-beta

  secret_id = "gke-endpoint"

  labels = {
    type    = "endpoint"
    cluster = google_container_cluster.primary.name
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "gke-endpoint-version" {
  provider = google-beta

  secret = google_secret_manager_secret.gke-endpoint.id

  secret_data = "https://${google_container_cluster.primary.endpoint}"
}
