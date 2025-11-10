# Grafana Client Certificate for mTLS authentication to observability services
resource "kubernetes_manifest" "grafana_client_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "grafana-client-cert"
      namespace = var.namespace
    }
    spec = {
      secretName = "grafana-client-cert-secret"
      commonName = "grafana.${var.namespace}.svc.cluster.local"
      duration   = var.certificate_duration
      renewBefore = var.certificate_renew_before
      
      dnsNames = [
        "grafana",
        "grafana.${var.namespace}",
        "grafana.${var.namespace}.svc",
        "grafana.${var.namespace}.svc.cluster.local"
      ]
      
      usages = [
        "digital signature",
        "key encipherment",
        "client auth"
      ]
      
      privateKey = {
        algorithm = "RSA"
        size      = 2048
      }
      
      issuerRef = {
        name  = var.ca_issuer_name
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }
}

# Loki Ingress TLS Certificate
resource "kubernetes_manifest" "loki_ingress_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "loki-ingress-cert"
      namespace = var.namespace
    }
    spec = {
      secretName = "loki-ingress-tls"
      commonName = "loki-${var.region_name}.${var.base_domain}"
      duration   = var.certificate_duration
      renewBefore = var.certificate_renew_before
      
      dnsNames = [
        "loki-${var.region_name}.${var.base_domain}"
      ]
      
      usages = [
        "digital signature",
        "key encipherment",
        "server auth"
      ]
      
      privateKey = {
        algorithm = "RSA"
        size      = 2048
      }
      
      issuerRef = {
        name  = var.enable_letsencrypt_ingress ? var.letsencrypt_issuer_name : var.ca_issuer_name
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }
}

# Mimir Ingress TLS Certificate
resource "kubernetes_manifest" "mimir_ingress_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "mimir-ingress-cert"
      namespace = var.namespace
    }
    spec = {
      secretName = "mimir-ingress-tls"
      commonName = "mimir-${var.region_name}.${var.base_domain}"
      duration   = var.certificate_duration
      renewBefore = var.certificate_renew_before
      
      dnsNames = [
        "mimir-${var.region_name}.${var.base_domain}"
      ]
      
      usages = [
        "digital signature",
        "key encipherment",
        "server auth"
      ]
      
      privateKey = {
        algorithm = "RSA"
        size      = 2048
      }
      
      issuerRef = {
        name  = var.enable_letsencrypt_ingress ? var.letsencrypt_issuer_name : var.ca_issuer_name
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }
}

# Tempo Ingress TLS Certificate
resource "kubernetes_manifest" "tempo_ingress_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "tempo-ingress-cert"
      namespace = var.namespace
    }
    spec = {
      secretName = "tempo-ingress-tls"
      commonName = "tempo-${var.region_name}.${var.base_domain}"
      duration   = var.certificate_duration
      renewBefore = var.certificate_renew_before
      
      dnsNames = [
        "tempo-${var.region_name}.${var.base_domain}"
      ]
      
      usages = [
        "digital signature",
        "key encipherment",
        "server auth"
      ]
      
      privateKey = {
        algorithm = "RSA"
        size      = 2048
      }
      
      issuerRef = {
        name  = var.enable_letsencrypt_ingress ? var.letsencrypt_issuer_name : var.ca_issuer_name
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }
}

# Developer Client Certificate for CLI access
resource "kubernetes_manifest" "developer_client_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "developer-client-cert"
      namespace = var.namespace
    }
    spec = {
      secretName = "developer-client-cert-secret"
      commonName = "developer.observability.local"
      duration   = var.certificate_duration
      renewBefore = var.certificate_renew_before
      
      dnsNames = [
        "developer.observability.local",
        "*.developer.observability.local"
      ]
      
      usages = [
        "digital signature",
        "key encipherment",
        "client auth"
      ]
      
      privateKey = {
        algorithm = "RSA"
        size      = 2048
      }
      
      issuerRef = {
        name  = var.ca_issuer_name
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }
}

# Wait for certificates to be ready
resource "time_sleep" "wait_for_certificates" {
  depends_on = [
    kubernetes_manifest.grafana_client_cert,
    kubernetes_manifest.loki_ingress_cert,
    kubernetes_manifest.mimir_ingress_cert,
    kubernetes_manifest.tempo_ingress_cert,
    kubernetes_manifest.developer_client_cert
  ]

  create_duration = "30s"
}
