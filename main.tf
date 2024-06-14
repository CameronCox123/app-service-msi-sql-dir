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

resource "azurerm_mssql_server" "server" {
  name                         = "cameron-cox-sql-server-for-terraform-deployment"
  resource_group_name          = "eastus"
  location                     = "myResourceGroup-15330"
  administrator_login          = "campatcox@gmail.com"
  administrator_login_password = "4PangoLinMM$"
  version                      = "12.0"
}

resource "azurerm_mssql_database" "db" {
  name                = "my-sql-db"
  server_id           = azurerm_mssql_server.server.id
}

data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

resource "azurerm_role_assignment" "example" {
  scope              = data.azurerm_subscription.current.id
  role_definition_id = "${data.azurerm_subscription.current.id}${data.azurerm_role_definition.contributor.id}"
  principal_id       = azurerm_virtual_machine.example.identity[0].principal_id
}
