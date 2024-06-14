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

resource "azurerm_service_plan" "example" {
  name                = "webapp-asp-${random_integer.ri.result}"
  location            = "eastus"
  resource_group_name = "myResourceGroup-15330"
  os_type             = "Windows"
  sku_name            = "B1"
}

resource "azurerm_windows_web_app" "example" {
  name                = "webapp-${random_integer.ri.result}"
  location            = "eastus"
  resource_group_name = "myResourceGroup-15330"
  service_plan_id     = azurerm_service_plan.example.id

  site_config {}
}
