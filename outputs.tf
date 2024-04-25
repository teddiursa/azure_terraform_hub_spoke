output "public_ip_address" {
  description = "Public IP address of the office network interface"
  value       = azurerm_public_ip.office_vm_public_ip.ip_address
}

output "webapp1_hostname" {
  description = "Hostname of webapp1"
  value       = "${azurerm_private_dns_a_record.webapp1_a_record.name}.${azurerm_private_dns_a_record.webapp1_a_record.zone_name}"
}


output "webapp1_private_endpoint" {
  description = "IP address of webapp1"
  value       = azurerm_private_endpoint.webapp1_private_endpoint.private_service_connection[0].private_ip_address
}

output "webapp2_hostname" {
  description = "Hostname of webapp2"
  value       = "${azurerm_private_dns_a_record.webapp2_a_record.name}.${azurerm_private_dns_a_record.webapp2_a_record.zone_name}"
}

output "webapp2_private_endpoint" {
  description = "IP address of webapp2"
  value       = azurerm_private_endpoint.webapp2_private_endpoint.private_service_connection[0].private_ip_address
}

output "sql_hostname" {
  description = "Hostname of the SQL server"
  value       = "${azurerm_private_dns_a_record.sql_a_record.name}.${azurerm_private_dns_a_record.sql_a_record.zone_name}"
}

output "sql_private_endpoint" {
  description = "IP address of the sql private endpoint"
  value       = azurerm_private_endpoint.sql_private_endpoint.private_service_connection[0].private_ip_address
}

output "spoke2_vm_hostname" {
  description = "Hostname of the spoke2 vm"
  value       = "${azurerm_private_dns_a_record.spoke2_vm_a_record.name}.${azurerm_private_dns_a_record.spoke2_vm_a_record.zone_name}"
}

output "hub_vm_hostname" {
  description = "Hostname of the hub vm"
  value       = "${azurerm_private_dns_a_record.hub_vm_a_record.name}.${azurerm_private_dns_a_record.hub_vm_a_record.zone_name}"
}

output "offic_vm_1_hostname" {
  description = "Hostname of the office vm 1"
  value       = "${azurerm_private_dns_a_record.office_vm_a_record.name}.${azurerm_private_dns_a_record.office_vm_a_record.zone_name}"
}
