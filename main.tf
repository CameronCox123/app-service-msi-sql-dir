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

# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-asp-${random_integer.ri.result}"
  location            = "eastus"
  resource_group_name = "myResourceGroup-15330"
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp" {
  name                  = "webapp-${random_integer.ri.result}"
  location              = "eastus"
  resource_group_name   = "myResourceGroup-15330"
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  https_only            = true

  site_config { 
    minimum_tls_version = "1.2"
  }

  identity {
    type = "SystemAssigned"
  }
}


# Create the SQL Server
resource "azurerm_mssql_server" "server" {
  name                         = "sqlserver-${random_integer.ri.result}"
  resource_group_name          = "myResourceGroup-15330"
  location                     = "eastus"
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "4PangoLinMM$"
}

# Create the SQL Database
resource "azurerm_mssql_database" "db" {
  name                = "my-sql-db"
  server_id           = azurerm_mssql_server.server.id
  resource_group_name = "myResourceGroup-15330"
  location            = "eastus"
  sku_name            = "S0"
}

# Get the current subscription
data "azurerm_subscription" "current" {}

# Get the built-in SQL Server Contributor role definition
data "azurerm_role_definition" "sql_contributor" {
  name = "SQL DB Contributor"
}

# Assign the SQL Server Contributor role to the Web App's MSI
resource "azurerm_role_assignment" "sql_contributor_assignment" {
  scope                = azurerm_mssql_server.server.id
  role_definition_id   = data.azurerm_role_definition.sql_contributor.id
  principal_id         = azurerm_linux_web_app.webapp.identity.principal_id
}
