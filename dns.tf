# Create a Private DNS Zone
resource "azurerm_private_dns_zone" "webapp_dns_zone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.office_rg.name
}

# Link the Private DNS Zone to the office vNet
resource "azurerm_private_dns_zone_virtual_network_link" "webapp_link" {
  name                  = "webapp-link-${random_pet.pet.id}"
  resource_group_name   = azurerm_resource_group.office_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.webapp_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.office_network.id
}

# Create DNS 'A' Record for webapp1
resource "azurerm_private_dns_a_record" "webapp1_a_record" {
  name                = azurerm_linux_web_app.webapp1.name
  zone_name           = azurerm_private_dns_zone.webapp_dns_zone.name
  resource_group_name = azurerm_resource_group.office_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.webapp1_private_endpoint.private_service_connection.0.private_ip_address]
#   depends_on = [
#     azurerm_private_dns_zone.webapp_dns_zone,
#     azurerm_private_dns_zone_virtual_network_link.webapp_link
#   ]
}

# Create DNS 'A' Record for webapp1 scm
resource "azurerm_private_dns_a_record" "webapp1_scm_record" {
  name                = "${azurerm_linux_web_app.webapp1.name}.scm"
  zone_name           = azurerm_private_dns_zone.webapp_dns_zone.name
  resource_group_name = azurerm_resource_group.office_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.webapp1_private_endpoint.private_service_connection.0.private_ip_address]
}


# Create DNS 'A' Record for webapp2
resource "azurerm_private_dns_a_record" "webapp2_a_record" {
  name                = azurerm_linux_web_app.webapp2.name
  zone_name           = azurerm_private_dns_zone.webapp_dns_zone.name
  resource_group_name = azurerm_resource_group.office_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.webapp2_private_endpoint.private_service_connection.0.private_ip_address]
}

# Create DNS 'A' Record for webapp2 scm
resource "azurerm_private_dns_a_record" "webapp2_scm_record" {
  name                = "${azurerm_linux_web_app.webapp2.name}.scm"
  zone_name           = azurerm_private_dns_zone.webapp_dns_zone.name
  resource_group_name = azurerm_resource_group.office_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.webapp2_private_endpoint.private_service_connection.0.private_ip_address]
}

# # Create DNS 'A' Record for Application Gateway
# resource "azurerm_private_dns_a_record" "appgw_a_record" {
#   name                = "appgw"
#   zone_name           = azurerm_private_dns_zone.webapp_dns_zone.name
#   resource_group_name = azurerm_resource_group.office_rg.name
#   ttl                 = 300
#   records             = [azurerm_application_gateway.appgw.frontend_ip_configuration[0].private_ip_address]
# }


# Create a Private DNS Zone
resource "azurerm_private_dns_zone" "sql_dns_zone" {
  name                = "database.windows.net"
  resource_group_name = azurerm_resource_group.office_rg.name
}

# Link the Private DNS Zone to the office vNet
resource "azurerm_private_dns_zone_virtual_network_link" "sql_link" {
  name                  = "sql-link-${random_pet.pet.id}"
  resource_group_name   = azurerm_resource_group.office_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.office_network.id
}


# Create DNS 'A' Record for SQL server
resource "azurerm_private_dns_a_record" "sql_a_record" {
  name                = azurerm_mssql_server.sqlserver.name
  zone_name           = azurerm_private_dns_zone.sql_dns_zone.name
  resource_group_name = azurerm_resource_group.office_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_private_endpoint.private_service_connection.0.private_ip_address]
}

# Create DNS 'A' Record for SQL server scm
resource "azurerm_private_dns_a_record" "sql_scm_record" {
  name                = "${azurerm_mssql_server.sqlserver.name}.scm"
  zone_name           = azurerm_private_dns_zone.sql_dns_zone.name
  resource_group_name = azurerm_resource_group.office_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_private_endpoint.private_service_connection.0.private_ip_address]
}
