# output "resource_group_name" {
#   description = "The name of the created resource group."
#   value       = azurerm_resource_group.rg.name
# }

# output "virtual_network_name" {
#   description = "The name of the created virtual network."
#   value       = azurerm_virtual_network.office_network.name
# }

# output "subnet_name_1" {
#   description = "The name of the created subnet 1."
#   value       = azurerm_subnet.main_subnet.name
# }

# output "subnet_name_2" {
#   description = "The name of the created subnet 2."
#   value       = azurerm_subnet.prod_subnet.name
# }

output "public_ip_address" {
  description = "Public IP address of the office network interface"
  value       = azurerm_public_ip.office_vm_public_ip.ip_address
}

# output "webapp_hostname" {
#   description = "Hostname of the webapp"
#   value       = azurerm_linux_web_app.webapp.default_hostname
# }

# output "webapp_private_endpoint" {
#   description = "IP address of the webapp private endpoint"
#   value       = azurerm_private_endpoint.webapp_private_endpoint.private_service_connection[0].private_ip_address
# }

output "webapp1_hostname" {
  description = "Hostname of webapp1"
  value       = azurerm_linux_web_app.webapp1.default_hostname
}

output "webapp1_private_endpoint" {
  description = "IP address of webapp1"
  value       = azurerm_private_endpoint.webapp1_private_endpoint.private_service_connection[0].private_ip_address
}

output "webapp2_hostname" {
  description = "Hostname of webapp2"
  value       = azurerm_linux_web_app.webapp2.default_hostname
}

output "webapp2_private_endpoint" {
  description = "IP address of webapp2"
  value       = azurerm_private_endpoint.webapp2_private_endpoint.private_service_connection[0].private_ip_address
}

# output "appgw_frontend_ip" {
#   description = "Frontend IP configuration of the Application Gateway"
#   value       = azurerm_application_gateway.appgw.frontend_ip_configuration[0].private_ip_address
# }

# output "webapp1_fqdn" {
#   description = "FQDN for webapp1"
#   value       = azurerm_private_dns_a_record.webapp1_a_record.records[0]
# }

# output "webapp2_scm_fqdn" {
#   description = "FQDN for webapp2 scm"
#   value       = azurerm_private_dns_a_record.webapp2_scm_record.records[0]
# }

# output "appgw_fqdn" {
#   description = "FQDN for Application Gateway"
#   value       = azurerm_private_dns_a_record.appgw_a_record.records[0]
# }

# output "appgw_fqdn" {
#   description = "FQDN for Application Gateway"
#   value       = tolist(azurerm_private_dns_a_record.appgw_a_record.records)[0]
# }

output "sql_hostname" {
  description = "Hostname of the SQL server"
  value       = azurerm_mssql_server.sqlserver.fully_qualified_domain_name
}

output "sql_private_endpoint" {
  description = "IP address of the sql private endpoint"
  value       = azurerm_private_endpoint.sql_private_endpoint.private_service_connection[0].private_ip_address
}
