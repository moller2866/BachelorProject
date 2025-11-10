# Create namespace for cert-manager
resource "kubernetes_namespace" "cert_manager" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/name"       = "cert-manager"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# Install cert-manager using Helm
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = var.namespace
  version    = var.chart_version

  # Wait for all resources to be ready
  wait          = true
  wait_for_jobs = true
  timeout       = 600

  # Install CRDs
  set {
    name  = "installCRDs"
    value = var.install_crds
  }

  # Controller configuration
  set {
    name  = "replicaCount"
    value = var.replica_count
  }

  # Webhook configuration
  set {
    name  = "webhook.replicaCount"
    value = var.webhook_replica_count
  }

  # CAInjector configuration
  set {
    name  = "cainjector.replicaCount"
    value = var.cainjector_replica_count
  }

  # Enable Prometheus metrics
  set {
    name  = "prometheus.enabled"
    value = var.enable_prometheus_metrics
  }

  # Security context
  set {
    name  = "global.priorityClassName"
    value = ""
  }

  # Resource limits (adjust based on your cluster size)
  set {
    name  = "resources.requests.cpu"
    value = "10m"
  }

  set {
    name  = "resources.requests.memory"
    value = "32Mi"
  }

  set {
    name  = "resources.limits.memory"
    value = "128Mi"
  }

  # Webhook resources
  set {
    name  = "webhook.resources.requests.cpu"
    value = "10m"
  }

  set {
    name  = "webhook.resources.requests.memory"
    value = "32Mi"
  }

  set {
    name  = "webhook.resources.limits.memory"
    value = "128Mi"
  }

  # CAInjector resources
  set {
    name  = "cainjector.resources.requests.cpu"
    value = "10m"
  }

  set {
    name  = "cainjector.resources.requests.memory"
    value = "32Mi"
  }

  set {
    name  = "cainjector.resources.limits.memory"
    value = "128Mi"
  }

  depends_on = [
    kubernetes_namespace.cert_manager
  ]
}

# Wait for cert-manager to be ready
resource "time_sleep" "wait_for_cert_manager" {
  depends_on = [helm_release.cert_manager]

  create_duration = "45s"
}
