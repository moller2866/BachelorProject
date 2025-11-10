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
        var.grafana_hostname != "" ? [var.grafana_hostname] : [],
        # Default Kubernetes DNS names (in case Grafana moves to k8s)
        [
          "grafana",
          "grafana.${var.grafana_namespace}",
          "grafana.${var.grafana_namespace}.svc",
          "grafana.${var.grafana_namespace}.svc.cluster.local"
        ]
      )

      issuerRef = {
        name  = var.ca_issuer_name
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }
}

# Unified Ingress TLS Certificate
# Single certificate for the shared ingress that serves all observability services
# Covers the main hostname used by the unified ingress
resource "kubernetes_manifest" "observability_ingress_cert" {
  count = var.enable_ingress_tls && var.base_domain != "" ? 1 : 0

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
        "ingress-type"                = "unified"
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

      # Common name is the main hostname
      commonName = var.ingress_hostname != "" ? var.ingress_hostname : "observability-${var.region_name}.${var.base_domain}"

      # DNS names - single hostname for the unified ingress
      dnsNames = [
        var.ingress_hostname != "" ? var.ingress_hostname : "observability-${var.region_name}.${var.base_domain}"
      ]

      issuerRef = {
        name  = var.ca_issuer_name
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }
}

# Developer Client Certificate (for CLI access)
# This can be extracted and used by developers for LogCLI, Mimirtool, etc.
resource "kubernetes_manifest" "developer_client_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "developer-client-cert"
      namespace = var.namespace
      labels = {
        "app.kubernetes.io/component" = "certificate"
        "app.kubernetes.io/part-of"   = "observability"
        "cert-purpose"                = "client-auth"
        "user-type"                   = "developer"
      }
    }
    spec = {
      secretName  = "developer-client-cert"
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
        organizations       = ["Observability"]
        organizationalUnits = ["Developers"]
      }

      commonName = "developer-cli-client"

      issuerRef = {
        name  = var.ca_issuer_name
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }
}
