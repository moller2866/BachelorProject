# Bootstrap self-signed issuer for creating the root CA
resource "kubernetes_manifest" "selfsigned_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "selfsigned-issuer"
    }
    spec = {
      selfSigned = {}
    }
  }

  depends_on = [
    time_sleep.wait_for_cert_manager,
    helm_release.cert_manager
  ]
}

# Root CA Certificate - this will be used to sign all internal certificates
resource "kubernetes_manifest" "root_ca_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "observability-root-ca"
      namespace = var.namespace
    }
    spec = {
      isCA        = true
      commonName  = var.ca_common_name
      secretName  = "observability-root-ca-secret"
      duration    = var.ca_duration
      renewBefore = var.ca_renew_before
      privateKey = {
        algorithm = "RSA"
        size      = 4096
      }
      issuerRef = {
        name  = "selfsigned-issuer"
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }

  depends_on = [
    kubernetes_manifest.selfsigned_issuer
  ]
}

# Wait for root CA to be ready
resource "time_sleep" "wait_for_root_ca" {
  depends_on = [kubernetes_manifest.root_ca_certificate]

  create_duration = "30s"
}

# CA ClusterIssuer - uses the root CA to sign certificates
resource "kubernetes_manifest" "ca_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "observability-ca-issuer"
    }
    spec = {
      ca = {
        secretName = "observability-root-ca-secret"
      }
    }
  }

  depends_on = [
    time_sleep.wait_for_root_ca
  ]
}
