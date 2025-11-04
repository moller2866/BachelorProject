terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.90.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_group" "grafana" {
  name                = "grafana-aci"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  container {
    name   = "grafana"
    image  = "grafana/grafana-oss:latest"
    cpu    = "0.5"
    memory = "1"

    ports {
      port     = 3000
      protocol = "TCP"
    }

    environment_variables = {
      GF_SECURITY_ADMIN_USER = var.grafana_user
      GF_SECURITY_ADMIN_PASSWORD = var.grafana_password
    }
  }

  exposed_port = [ 
    {
      port     = 3000
      protocol = "TCP"
    }
 ]
  ip_address_type = "Public"
  dns_name_label  = var.dns_name_label
}
