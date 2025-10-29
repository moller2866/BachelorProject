# Install NGINX Ingress Controller (optional)
resource "helm_release" "nginx_ingress" {
  count = var.install_nginx_controller ? 1 : 0

  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = var.namespace
  version    = var.nginx_controller_version

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

# Wait for the ingress controller to be ready
resource "time_sleep" "wait_for_ingress_controller" {
  count = var.install_nginx_controller ? 1 : 0

  depends_on = [helm_release.nginx_ingress]

  create_duration = "30s"
}

# Unified Ingress for Observability Services
resource "kubernetes_ingress_v1" "observability" {
  metadata {
    name      = "observability-ingress"
    namespace = var.namespace

    annotations = merge(
      {
        "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
        "nginx.ingress.kubernetes.io/use-regex"      = "true"
        "nginx.ingress.kubernetes.io/ssl-redirect"   = var.enable_tls ? "true" : "false"
      },
      var.additional_annotations
    )
  }

  spec {
    ingress_class_name = var.ingress_class_name

    # TLS configuration (optional)
    dynamic "tls" {
      for_each = var.enable_tls && var.host != "" ? [1] : []
      content {
        hosts       = [var.host]
        secret_name = var.tls_secret_name
      }
    }

    # Rule for IP-based or hostname-based access
    rule {
      host = var.host != "" ? var.host : null

      http {
        # Loki path
        path {
          path      = "/loki(/|$)(.*)"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = var.loki_service_name
              port {
                number = var.loki_service_port
              }
            }
          }
        }

        # Mimir path
        path {
          path      = "/mimir(/|$)(.*)"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = var.mimir_service_name
              port {
                number = var.mimir_service_port
              }
            }
          }
        }

        # Tempo path
        path {
          path      = "/tempo(/|$)(.*)"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = var.tempo_service_name
              port {
                number = var.tempo_service_port
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    time_sleep.wait_for_ingress_controller
  ]
}

# Data source to get the LoadBalancer IP
data "kubernetes_service" "nginx_ingress_controller" {
  count = var.install_nginx_controller ? 1 : 0

  metadata {
    name      = "ingress-nginx-controller"
    namespace = var.namespace
  }

  depends_on = [
    helm_release.nginx_ingress,
    time_sleep.wait_for_ingress_controller
  ]
}
