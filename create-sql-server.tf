# Create the SQL Server
resource "azurerm_mssql_server" "sqlserver" {
  name                         = "mysqlserver-${random_integer.ri.result}"
  resource_group_name          = "myResourceGroup-68452"
  location                     = "eastus"
  version                      = "12.0"
  administrator_login          = "campatcox@gmail.com"
  administrator_login_password = "4PangoLinMM$"
}

# Create the SQL Database
resource "azurerm_sql_database" "sqldatabase" {
  name                = "mydatabase"
  resource_group_name = "myResourceGroup-68452"
  location            = "eastus"
  server_name         = azurerm_mssql_server.sqlserver.name
}

# Assign MSI of App Service as Azure AD Admin on SQL Server
resource "azuread_administrator" "example" {
  server_name         = azurerm_mssql_server.sqlserver.name
  resource_group_name = "myResourceGroup-68452"
  login               = azurerm_linux_web_app.webapp.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = azurerm_linux_web_app.webapp.identity[0].principal_id
}

# Data source to get the current tenant ID
data "azurerm_client_config" "current" {}
