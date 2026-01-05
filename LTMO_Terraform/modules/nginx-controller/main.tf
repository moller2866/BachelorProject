# NGINX Ingress Controller Module
# This module only deploys the NGINX Ingress Controller and exposes the LoadBalancer IP
# The ingress resources are created separately to avoid circular dependencies

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = var.namespace
  version    = var.chart_version

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.ingressClassResource.name"
    value = var.ingress_class_name
  }

  set {
    name  = "controller.ingressClassResource.enabled"
    value = "true"
  }

  set {
    name  = "controller.ingressClassResource.default"
    value = "true"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
}

# Wait for the LoadBalancer to get an IP
resource "time_sleep" "wait_for_lb" {
  depends_on = [helm_release.nginx_ingress]

  create_duration = "60s"
}

# Data source to get the LoadBalancer IP
data "kubernetes_service" "nginx_ingress_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = var.namespace
  }

  depends_on = [
    helm_release.nginx_ingress,
    time_sleep.wait_for_lb
  ]
}
