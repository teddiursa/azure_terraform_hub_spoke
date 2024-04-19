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

output "webapp_hostname" {
  description = "Hostname of the webapp"
  value       = azurerm_linux_web_app.webapp.default_hostname
}

output "webapp_private_endpoint" {
  description = "IP address of the webapp private endpoint"
  value       = azurerm_private_endpoint.webapp_private_endpoint.private_service_connection[0].private_ip_address
}
