output "service_account_token" {
  value = kubernetes_secret.sa-key.data.token
}

output "namespace" {
  value = local.ns
}
