resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

locals {
  vaultNs = kubernetes_namespace.vault.metadata.0.name
  vaultLabels = {
    "app.kubernetes.io/name"    = "vault"
    "app.kubernetes.io/part-of" = "vault"
  }
}

resource "kubernetes_secret" "vault-svcacct" {
  metadata {
    generate_name = "vault-svcacct"
    namespace     = local.vaultNs
    labels        = local.vaultLabels
  }

  data = {
    "vault-service-account.json" = var.vault_gcs_token
  }
}

resource "kubernetes_config_map" "vault-cm" {
  metadata {
    generate_name = "vault-config"
    namespace     = local.vaultNs
    labels        = local.vaultLabels
  }

  data = {
    "vault-config.json" = jsonencode({
      // Enables UI
      ui = true,

      // Storage with GCS
      storage = {
        gcs = {
          bucket = "roleypoly-vault"
        }
      },

      // Auto-seal setup with GCPKMS
      seal = {
        gcpkms = {
          credentials = "/vault/mounted-secrets/vault-service-account.json",
          project     = var.gcp_project
          region      = "global"
          key_ring    = "vault-keyring"
          crypto_key  = "vault-key"
        }
      },

      // TCP
      listener = {
        tcp = {
          address = "0.0.0.0:8200"
        }
      }
    })
  }
}

resource "kubernetes_pod" "vault" {
  metadata {
    name      = "vault"
    namespace = local.vaultNs
    labels    = local.vaultLabels
  }

  spec {
    container {
      image = "vault:1.4.2"
      name  = "vault"

      volume_mount {
        mount_path = "/vault/mounted-secrets"
        name       = "vault-secrets"
        read_only  = true
      }
      volume_mount {
        mount_path = "/vault/config"
        name       = "vault-config"
        read_only  = true
      }

      security_context {
        capabilities {
          add = ["IPC_LOCK"]
        }
      }
    }

    node_selector = {
      node_type = "static"
    }

    restart_policy = "Always"

    volume {
      name   = "vault-secrets"
      secret {
        secret_name = kubernetes_secret.vault-svcacct.metadata.0.name
      }
    }

    volume {
      name      = "vault-config"
      configmap {
        name = kubernetes_config_map.vault-cm.metadata.0.name
      }
    }
  }
}