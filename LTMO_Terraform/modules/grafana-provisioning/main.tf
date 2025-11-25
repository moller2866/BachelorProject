terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 2.6"
    }
  }
}

resource "grafana_data_source" "loki" {
  name = "Loki"
  type = "loki"
  url  = var.loki_url

  http_headers = {
    "X-Scope-OrgID" = "tenant1"
  }

  # mTLS configuration (only applied if enabled)
  secure_json_data_encoded = var.enable_mtls ? jsonencode({
    tlsClientCert = var.grafana_client_cert
    tlsClientKey  = var.grafana_client_key
    tlsCACert     = var.ca_cert
  }) : null

  json_data_encoded = jsonencode({
    tlsAuth           = var.enable_mtls
    tlsAuthWithCACert = var.enable_mtls
    tlsSkipVerify     = var.tls_skip_verify
  })
}

resource "grafana_data_source" "tempo" {
  name = "Tempo"
  type = "tempo"
  url  = var.tempo_url

  http_headers = {
    "X-Scope-OrgID" = "tenant1"
  }

  # mTLS configuration (only applied if enabled)
  secure_json_data_encoded = var.enable_mtls ? jsonencode({
    tlsClientCert = var.grafana_client_cert
    tlsClientKey  = var.grafana_client_key
    tlsCACert     = var.ca_cert
  }) : null

  json_data_encoded = jsonencode({
    tlsAuth           = var.enable_mtls
    tlsAuthWithCACert = var.enable_mtls
    tlsSkipVerify     = var.tls_skip_verify
  })
}

resource "grafana_data_source" "mimir" {
  name = "Mimir"
  type = "prometheus"
  url  = var.mimir_url

  http_headers = {
    "X-Scope-OrgID" = "tenant1"
  }

  # mTLS configuration (only applied if enabled)
  secure_json_data_encoded = var.enable_mtls ? jsonencode({
    tlsClientCert = var.grafana_client_cert
    tlsClientKey  = var.grafana_client_key
    tlsCACert     = var.ca_cert
  }) : null

  json_data_encoded = jsonencode({
    prometheusType    = "Mimir"
    prometheusVersion = "2.9.1"
    tlsAuth           = var.enable_mtls
    tlsAuthWithCACert = var.enable_mtls
    tlsSkipVerify     = var.tls_skip_verify
  })
}
