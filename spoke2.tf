# # Resource Group
# resource "azurerm_resource_group" "spoke2_rg" {
#   location = var.resource_group_location
#   name     = "spoke2-rg"
# }

# resource "azurerm_virtual_network" "spoke2_vnet" {
#   name                = "spoke2-vnet"
#   resource_group_name = azurerm_resource_group.spoke2_rg.name
#   location            = azurerm_resource_group.spoke2_rg.location
#   address_space       = ["10.2.0.0/16"]

#   tags = {
#     environment = "spoke2"
#   }
# }

# resource "azurerm_subnet" "spoke2_mgmt" {
#   name                 = "mgmt"
#   resource_group_name = azurerm_resource_group.spoke2_rg.name
#   virtual_network_name = azurerm_virtual_network.spoke2_vnet.name
#   address_prefixes     = ["10.2.0.64/27"]
# }

# resource "azurerm_subnet" "spoke2_workload" {
#   name                 = "workload"
#   resource_group_name = azurerm_resource_group.spoke2_rg.name
#   virtual_network_name = azurerm_virtual_network.spoke2_vnet.name
#   address_prefixes     = ["10.2.1.0/24"]
# }

# resource "azurerm_virtual_network_peering" "spoke2_hub_peer" {
#   name                      = "spoke2-hub-peer"
#   resource_group_name       = azurerm_resource_group.spoke2_rg.name
#   virtual_network_name      = azurerm_virtual_network.spoke2_vnet.name
#   remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id

#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true
#   allow_gateway_transit        = false
#   use_remote_gateways          = true
#   depends_on                   = [azurerm_virtual_network.spoke2_vnet, azurerm_virtual_network.hub_vnet, azurerm_virtual_network_gateway.hub_vnet_gateway]
# }

# resource "azurerm_network_interface" "spoke2_nic" {
#   name                 = "spoke2-vm-nic"
#   resource_group_name  = azurerm_resource_group.spoke2_rg.name
#   location             = azurerm_resource_group.spoke2_rg.location
#   enable_ip_forwarding = true

#   ip_configuration {
#     name                          = "spoke2-vm"
#     subnet_id                     = azurerm_subnet.spoke2_mgmt.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# resource "azurerm_virtual_machine" "spoke2_vm" {
#   name                  = "spoke2-vm"
#   resource_group_name   = azurerm_resource_group.spoke2_rg.name
#   location              = azurerm_resource_group.spoke2_rg.location
#   network_interface_ids = [azurerm_network_interface.spoke2_nic.id]
#   vm_size               = var.vmsize

#   storage_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "16.04-LTS"
#     version   = "latest"
#   }

#   storage_os_disk {
#     name              = "myosdisk1"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }

#   os_profile {
#     computer_name  = "spoke2-vm"
#     admin_username = "greg"
#     admin_password = var.azure_password
#   }

#   os_profile_linux_config {
#     disable_password_authentication = false
#   }

#   tags = {
#     environment = "spoke2"
#   }
# }

# resource "azurerm_virtual_network_peering" "hub_spoke2_peer" {
#   name                         = "hub-spoke2-peer"
#   resource_group_name          = azurerm_resource_group.hub_net_rg.name
#   virtual_network_name         = azurerm_virtual_network.hub_vnet.name
#   remote_virtual_network_id    = azurerm_virtual_network.spoke2_vnet.id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true
#   allow_gateway_transit        = true
#   use_remote_gateways          = false
#   depends_on                   = [azurerm_virtual_network.spoke2_vnet, azurerm_virtual_network.hub_vnet, azurerm_virtual_network_gateway.hub_vnet_gateway]
# }
