# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup-${random_integer.ri.result}"
  location = "eastus"
}

# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-asp-${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp" {
  name                  = "webapp-${random_integer.ri.result}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  https_only            = true

  site_config { 
    minimum_tls_version = "1.2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "sourcecontrol" {
  app_id                 = azurerm_linux_web_app.webapp.id
  repo_url               = "https://github.com/Azure-Samples/nodejs-docs-hello-world"
  branch                 = "master"
  use_manual_integration = true
  use_mercurial          = false
}

# Output the Principal ID of the MSI
output "msi_principal_id" {
  value = azurerm_linux_web_app.webapp.identity[0].principal_id
}

resource "azurerm_mssql_server" "server" {
  name                         = "my-sql-server"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  administrator_login          = "campatcox@gmail.com"
  administrator_login_password = "4PangoLinMM$"
  version                      = "12.0"
}

resource "azurerm_mssql_database" "db" {
  name                = "my-sql-db"
  resource_group_name = azurerm_resource_group.rg.name
  server_id           = azurerm_mssql_server.server.id
}

# Assign MSI of App Service as Azure AD Admin on SQL Server
resource "azurerm_sql_active_directory_administrator" "example" {
  server_name         = "my-sql-server"
  resource_group_name = azurerm_resource_group.rg.name
  login               = azurerm_linux_web_app.webapp.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = azurerm_linux_web_app.webapp.identity[0].principal_id
}

# Data source to get the current tenant ID
data "azurerm_client_config" "current" {}
