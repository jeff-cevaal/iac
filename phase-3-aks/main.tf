terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "1220b143-c325-4c0f-876f-e348b99f8cb9"
}

resource "azurerm_resource_group" "aks" {
  name     = "rg-cloud-course-aks"
  location = "Central US"
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "iac-cluster"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "iac"
  kubernetes_version  = "1.35"

  node_provisioning_profile {
    mode = "Manual"
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
  }

}

# DB

resource "azurerm_postgresql_flexible_server" "n8n_db" {

  name                = "psql-n8n-iac"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  zone                = "2"

  administrator_login    = "n8nadmin"
  administrator_password = "n8n-password-123"

  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768
  version    = "16"

  backup_retention_days = 7

  # Allow Azure services to access (needed for AKS)
  public_network_access_enabled = true
}

resource "azurerm_postgresql_flexible_server_configuration" "disable_ssl" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.n8n_db.id
  value     = "OFF"
}

resource "azurerm_postgresql_flexible_server_database" "n8n" {
  name      = "n8n"
  server_id = azurerm_postgresql_flexible_server.n8n_db.id
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.n8n_db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

output "db_host" {
  value = azurerm_postgresql_flexible_server.n8n_db.fqdn
}

output "db_name" {
  value = azurerm_postgresql_flexible_server_database.n8n.name
}

output "db_user" {
  value = azurerm_postgresql_flexible_server.n8n_db.administrator_login
}