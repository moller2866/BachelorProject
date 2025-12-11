# Ingress TLS Certificate for HTTPS

# This certificate secures the ingress endpoint with TLS/HTTPS
resource "kubernetes_manifest" "ingress_tls_cert" {
  count = var.enable_ingress_tls ? 1 : 0

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "observability-ingress-tls"
      namespace = var.namespace
      labels = {
        "app.kubernetes.io/component" = "certificate"
        "app.kubernetes.io/part-of"   = "observability"
        "cert-purpose"                = "server-auth"
      }
    }
    spec = {
      secretName  = "observability-ingress-tls"
      duration    = var.certificate_duration
      renewBefore = var.certificate_renew_before

      usages = [
        "digital signature",
        "key encipherment",
        "server auth"
      ]

      privateKey = {
        algorithm = "RSA"
        size      = 2048
      }

      subject = {
        organizations = ["Observability"]
      }

      commonName = var.ingress_hostname != "" ? var.ingress_hostname : (var.base_domain != "" ? "observability-${var.region_name}.${var.base_domain}" : "observability.local")

      dnsNames = concat(
        # Always include the common name
        [var.ingress_hostname != "" ? var.ingress_hostname : (var.base_domain != "" ? "observability-${var.region_name}.${var.base_domain}" : "observability.local")],
        # Include additional DNS names (e.g., IP.nip.io hostnames)
        var.additional_dns_names
      )

      issuerRef = {
        name  = var.ca_issuer_name
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }
}

# Grafana Client Certificate for mTLS Authentication

# This certificate will be used by Grafana to authenticate to Loki, Mimir, and Tempo
resource "kubernetes_manifest" "grafana_client_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "grafana-client-cert"
      namespace = var.namespace
      labels = {
        "app.kubernetes.io/component" = "certificate"
        "app.kubernetes.io/part-of"   = "observability"
        "cert-purpose"                = "client-auth"
      }
    }
    spec = {
      secretName  = "grafana-client-cert"
      duration    = var.certificate_duration
      renewBefore = var.certificate_renew_before

      usages = [
        "digital signature",
        "key encipherment",
        "client auth"
      ]

      privateKey = {
        algorithm = "RSA"
        size      = 2048
      }

      subject = {
        organizations = ["Observability"]
      }

      commonName = "grafana-client"

      dnsNames = concat(
        # If grafana_hostname is provided, use it
        var.grafana_hostname != "" ? [var.grafana_hostname] : []
      )

      issuerRef = {
        name  = var.ca_issuer_name
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }
}
