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