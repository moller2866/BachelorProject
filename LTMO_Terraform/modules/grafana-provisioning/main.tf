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
}

resource "grafana_data_source" "tempo" {
  name = "Tempo"
  type = "tempo"
  url  = var.tempo_url

  http_headers = {
    "X-Scope-OrgID" = "tenant1"
  }
}

resource "grafana_data_source" "mimir" {
  name = "Mimir"
  type = "prometheus"
  url  = var.mimir_url

  http_headers = {
    "X-Scope-OrgID" = "tenant1"
  }
  json_data_encoded = jsonencode({
    prometheusType    = "Mimir"
    prometheusVersion = "2.9.1"
  })
}
