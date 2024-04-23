resource "azurerm_resource_group" "sql_rg" {
  name     = "sql-rg-${random_pet.pet.id}"
  location = var.resource_cloud_group_location
}

# Create an Azure SQL Server
resource "azurerm_mssql_server" "sqlserver" {
  name                         = "sqlserver-${random_pet.pet.id}"
  resource_group_name          = azurerm_resource_group.sql_rg.name
  location                     = azurerm_resource_group.sql_rg.location
  version                      = "12.0"
  administrator_login          = var.azure_user
  administrator_login_password = var.azure_password
}

# Create an Azure SQL Database
resource "azurerm_mssql_database" "sqldb" {
  name         = "sqldb-${random_pet.pet.id}"
  server_id    = azurerm_mssql_server.sqlserver.id
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  #   read_scale     = true
  sku_name       = "S0"
  zone_redundant = false
  enclave_type   = "VBS"
  depends_on = [
    azurerm_mssql_server.sqlserver
  ]
}


# Create a private endpoint for SQL server in spoke2_workload subnet
resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "sql-endpoint-${random_pet.pet.id}"
  location            = azurerm_resource_group.sql_rg.location
  resource_group_name = azurerm_resource_group.sql_rg.name
  subnet_id           = azurerm_subnet.spoke2_workload.id

  private_service_connection {
    name                           = "sql-privateserviceconnection-${random_pet.pet.id}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mssql_server.sqlserver.id
    subresource_names              = ["sqlServer"]
  }
}

