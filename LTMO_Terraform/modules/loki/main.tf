# Generate htpasswd for basic auth
resource "random_password" "loki_password" {
  length  = 16
  special = true
}

locals {
  loki_username = "loki"
  loki_password = random_password.loki_password.result
}

# Create basic auth secret for Loki
resource "kubernetes_secret" "loki_basic_auth" {
  metadata {
    name      = "loki-basic-auth"
    namespace = var.namespace
  }

  data = {
    ".htpasswd" = "${local.loki_username}:${htpasswd_password.loki.apr1}"
  }
}

# Generate htpasswd hash
resource "htpasswd_password" "loki" {
  password = local.loki_password
  salt     = substr(md5(local.loki_password), 0, 8)
}

# Create canary basic auth secret
resource "kubernetes_secret" "canary_basic_auth" {
  metadata {
    name      = "canary-basic-auth"
    namespace = var.namespace
  }

  data = {
    username = local.loki_username
    password = local.loki_password
  }
}

# Add Grafana Helm repository
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = var.namespace
  version    = "5.47.2" # Specify version for consistency

  values = [
    templatefile("${path.module}/loki-values.yaml.tpl", {
      storage_account_name        = var.storage_account_name
      loki_chunk_container        = var.loki_chunk_container
      loki_ruler_container        = var.loki_ruler_container
      service_account_name        = var.service_account_name
      workload_identity_client_id = var.workload_identity_client_id
    })
  ]

  depends_on = [
    kubernetes_secret.loki_basic_auth,
    kubernetes_secret.canary_basic_auth
  ]
}

# Get Loki gateway service to output external IP
data "kubernetes_service" "loki_gateway" {
  metadata {
    name      = "${helm_release.loki.name}-gateway"
    namespace = var.namespace
  }

  depends_on = [helm_release.loki]
}
