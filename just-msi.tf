resource "azurerm_user_assigned_identity" "example" {
  location            = "eastus"
  name                = "example"
  resource_group_name = "myResourceGroup-15330"
}
