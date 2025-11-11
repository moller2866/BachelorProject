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
