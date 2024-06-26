# Private DNS Zone
resource "azurerm_private_dns_zone" "dns_zone" {
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.office_rg.name
}

# Link Private DNS Zone to office vNet
resource "azurerm_private_dns_zone_virtual_network_link" "office_link" {
  name                  = "office-link-${random_pet.pet.id}"
  resource_group_name   = azurerm_resource_group.office_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = azurerm_virtual_network.office_network.id
}

# DNS 'A' Record for SQL server
resource "azurerm_private_dns_a_record" "sql_a_record" {
  name                = azurerm_mssql_server.sqlserver.name
  zone_name           = azurerm_private_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.office_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_private_endpoint.private_service_connection.0.private_ip_address]
}

# DNS 'A' Record for SQL server scm
resource "azurerm_private_dns_a_record" "sql_scm_record" {
  name                = "${azurerm_mssql_server.sqlserver.name}.scm"
  zone_name           = azurerm_private_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.office_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_private_endpoint.private_service_connection.0.private_ip_address]
}

# DNS 'A' Record for spoke 2 vm
resource "azurerm_private_dns_a_record" "spoke2_vm_a_record" {
  name                = "spoke2"
  zone_name           = azurerm_private_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.office_rg.name
  ttl                 = 300

  records = [azurerm_network_interface.spoke2_nic.ip_configuration[0].private_ip_address]
}

# DNS 'A' Record for hub vm
resource "azurerm_private_dns_a_record" "hub_vm_a_record" {
  name                = "hub"
  zone_name           = azurerm_private_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.office_rg.name
  ttl                 = 300

  records = [azurerm_network_interface.hub_nva_nic.ip_configuration[0].private_ip_address]
}

# DNS 'A' Record for office vm
resource "azurerm_private_dns_a_record" "office_vm_a_record" {
  name                = "office-vm-1"
  zone_name           = azurerm_private_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.office_rg.name
  ttl                 = 300

  records = [azurerm_network_interface.office_nic_1.ip_configuration[0].private_ip_address]
}



# Using default domain for webapps

# Default DNS Zone
resource "azurerm_private_dns_zone" "default_dns_zone" {
  name                = "azurewebsites.net"
  resource_group_name = azurerm_resource_group.office_rg.name
}


# Link default DNS Zone to office vNet
resource "azurerm_private_dns_zone_virtual_network_link" "default_link" {
  name                  = "default-link-${random_pet.pet.id}"
  resource_group_name   = azurerm_resource_group.office_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.default_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.office_network.id
}

# DNS 'A' Record for webapp1
resource "azurerm_private_dns_a_record" "webapp1_a_record" {
  name                = azurerm_linux_web_app.webapp1.name
  zone_name           = azurerm_private_dns_zone.default_dns_zone.name
  resource_group_name = azurerm_resource_group.office_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.webapp1_private_endpoint.private_service_connection.0.private_ip_address]
#   depends_on = [
#     azurerm_private_dns_zone.webapp_dns_zone,
#     azurerm_private_dns_zone_virtual_network_link.webapp_link
#   ]
}

# DNS 'A' Record for webapp1 scm
resource "azurerm_private_dns_a_record" "webapp1_scm_record" {
  name                = "${azurerm_linux_web_app.webapp1.name}.scm"
  zone_name           = azurerm_private_dns_zone.default_dns_zone.name
  resource_group_name = azurerm_resource_group.office_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.webapp1_private_endpoint.private_service_connection.0.private_ip_address]
}


# DNS 'A' Record for webapp2
resource "azurerm_private_dns_a_record" "webapp2_a_record" {
  name                = azurerm_linux_web_app.webapp2.name
  zone_name           = azurerm_private_dns_zone.default_dns_zone.name
  resource_group_name = azurerm_resource_group.office_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.webapp2_private_endpoint.private_service_connection.0.private_ip_address]
}

# DNS 'A' Record for webapp2 scm
resource "azurerm_private_dns_a_record" "webapp2_scm_record" {
  name                = "${azurerm_linux_web_app.webapp2.name}.scm"
  zone_name           = azurerm_private_dns_zone.default_dns_zone.name
  resource_group_name = azurerm_resource_group.office_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.webapp2_private_endpoint.private_service_connection.0.private_ip_address]
}

# # txt records for webapp custom domains
# resource "azurerm_dns_txt_record" "webapp1_txt_record" {
#   name                = "asuid.${azurerm_linux_web_app.webapp1.name}"
#   zone_name           = azurerm_dns_zone.public_dns_zone.name
#   resource_group_name = azurerm_resource_group.webapp_rg.name
#   ttl                 = 300
#   record {
#     value = azurerm_linux_web_app.webapp1.custom_domain_verification_id
#   }
# }

# # txt records for webapp custom domains
# resource "azurerm_dns_txt_record" "webapp2_txt_record" {
#   name                = "asuid.${azurerm_linux_web_app.webapp2.name}"
#   zone_name           = azurerm_dns_zone.public_dns_zone.name
#   resource_group_name = azurerm_resource_group.webapp_rg.name
#   ttl                 = 300
#   record {
#     value = azurerm_linux_web_app.webapp2.custom_domain_verification_id
#   }
# }