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
  description = "Public IP address of the network interface"
  value       = azurerm_public_ip.office_vm_public_ip.ip_address
}
