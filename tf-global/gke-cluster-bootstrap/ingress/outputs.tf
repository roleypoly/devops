output "service-name" {
  value = kubernetes_service.svc.metadata.0.name
}

output "service-namespace" {
  value = kubernetes_service.svc.metadata.0.namespace
}
