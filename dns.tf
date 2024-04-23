# Create a Private DNS Zone
resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.webapp_rg.name
}

# Link the Private DNS Zone to the office vNet
resource "azurerm_private_dns_zone_virtual_network_link" "webapp_link" {
  name                  = "webapp-link-${random_pet.pet.id}"
  resource_group_name   = azurerm_resource_group.webapp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = azurerm_virtual_network.office_network.id
}

# Create a DNS 'A' Record for webapp
resource "azurerm_private_dns_a_record" "webapp_a_record" {
  name                = "webapp-${random_pet.pet.id}"
  zone_name           = azurerm_private_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.webapp_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.webapp_private_endpoint.private_service_connection.0.private_ip_address]
}

# name = ${azurerm_linux_web_app.webapp.name} ?

# Create a DNS 'A' Record for webapp scm
resource "azurerm_private_dns_a_record" "webapp_scm_record" {
  name                = "webapp-${random_pet.pet.id}.scm"  
  zone_name           = azurerm_private_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.webapp_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.webapp_private_endpoint.private_service_connection.0.private_ip_address]
}
