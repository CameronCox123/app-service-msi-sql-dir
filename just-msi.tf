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

resource "azurerm_user_assigned_identity" "example" {
  location            = "eastus"
  name                = "example"
  resource_group_name = "myResourceGroup-15330"
}
