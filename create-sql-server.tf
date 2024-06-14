resource "azurerm_mssql_server" "server" {
  name                         = "my-sql-server"
  resource_group_name          = "myResourceGroup-68452"
  location                     = "eastus"
  administrator_login          = "campatcox@gmail.com"
  administrator_login_password = "4PangoLinMM$"
  version                      = "12.0"
}

resource "azurerm_mssql_database" "db" {
  name      = "my-sql-db"
  server_id = azurerm_mssql_server.server.id
}

# Assign MSI of App Service as Azure AD Admin on SQL Server
resource "azurerm_sql_active_directory_administrator" "example" {
  server_name         = "my-sql-server"
  resource_group_name = "myResourceGroup-68452"
  login               = azurerm_linux_web_app.webapp.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = azurerm_linux_web_app.webapp.identity[0].principal_id
}

# Data source to get the current tenant ID
data "azurerm_client_config" "current" {}
