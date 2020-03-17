resource "google_container_cluster" "primary" {
  location = "us-east1-a"

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_static_nodes" {
  location   = "us-east1-a"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 3

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
