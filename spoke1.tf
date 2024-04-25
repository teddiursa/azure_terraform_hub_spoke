# Resource Group
resource "azurerm_resource_group" "spoke1_rg" {
  location = var.resource_cloud_group_location
  name     = "spoke1-rg-${random_pet.pet.id}"
}

resource "azurerm_virtual_network" "spoke1_vnet" {
  name                = "spoke1-vnet-${random_pet.pet.id}"
  resource_group_name = azurerm_resource_group.spoke1_rg.name
  location            = azurerm_resource_group.spoke1_rg.location
  address_space       = [var.spoke1_vnet_prefix]

  tags = {
    environment = "spoke1"
  }
  depends_on = [azurerm_resource_group.spoke1_rg]
}

resource "azurerm_subnet" "spoke1_mgmt" {
  name                 = "mgmt-${random_pet.pet.id}"
  resource_group_name  = azurerm_resource_group.spoke1_rg.name
  virtual_network_name = azurerm_virtual_network.spoke1_vnet.name
  address_prefixes     = [var.spoke1_mgmt_subnet_prefix]
  depends_on           = [azurerm_virtual_network.spoke1_vnet]
}

resource "azurerm_subnet" "spoke1_workload" {
  name                 = "workload-${random_pet.pet.id}"
  resource_group_name  = azurerm_resource_group.spoke1_rg.name
  virtual_network_name = azurerm_virtual_network.spoke1_vnet.name
  address_prefixes     = [var.spoke1_workload_subnet_prefix]


  depends_on = [azurerm_virtual_network.spoke1_vnet]
}

# NSGs

resource "azurerm_network_security_group" "spoke1_nsg" {
  name                = "spoke1-nsg-${random_pet.pet.id}"
  resource_group_name = azurerm_resource_group.spoke1_rg.name
  location            = azurerm_resource_group.spoke1_rg.location
}

# Allow HTTP and HTTPS traffic to workload subnet from mgmt subnet


resource "azurerm_network_security_rule" "web_rule" {
  name                        = "AllowWeb"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443"]
  source_address_prefix       = var.office_mgmt_subnet_prefix
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.spoke1_rg.name
  network_security_group_name = azurerm_network_security_group.spoke1_nsg.name
}

# Block HTTP and HTTPS from all other networks

resource "azurerm_network_security_rule" "http_rule" {
  name                        = "BlockWeb"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.spoke1_rg.name
  network_security_group_name = azurerm_network_security_group.spoke1_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "spoke1_nsg_assoc" {
  subnet_id                 = azurerm_subnet.spoke1_workload.id
  network_security_group_id = azurerm_network_security_group.spoke1_nsg.id
}


# Network Peering

resource "azurerm_virtual_network_peering" "spoke1_hub_peer" {
  name                      = "spoke1-hub-peer-${random_pet.pet.id}"
  resource_group_name       = azurerm_resource_group.spoke1_rg.name
  virtual_network_name      = azurerm_virtual_network.spoke1_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
  depends_on                   = [azurerm_virtual_network.spoke1_vnet, azurerm_virtual_network.hub_vnet, azurerm_virtual_network_gateway.hub_vnet_gateway]
}

# resource "azurerm_network_interface" "spoke1_nic" {
#   name                 = "spoke1-vm-nic-${random_pet.pet.id}"
#   resource_group_name  = azurerm_resource_group.spoke1_rg.name
#   location             = azurerm_resource_group.spoke1_rg.location
#   enable_ip_forwarding = true

#   ip_configuration {
#     name                          = "spoke1-vm"
#     subnet_id                     = azurerm_subnet.spoke1_mgmt.id
#     private_ip_address_allocation = "Dynamic"
#   }
#   depends_on = [azurerm_subnet.spoke1_mgmt]
# }

# resource "azurerm_virtual_machine" "spoke1_vm" {
#   name                          = "spoke1-vm-${random_pet.pet.id}"
#   resource_group_name           = azurerm_resource_group.spoke1_rg.name
#   location                      = azurerm_resource_group.spoke1_rg.location
#   network_interface_ids         = [azurerm_network_interface.spoke1_nic.id]
#   vm_size                       = var.vmsize
#   delete_os_disk_on_termination = true

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
#     computer_name  = "spoke1-vm"
#     admin_username = var.azure_user
#     admin_password = var.azure_password
#   }

#   os_profile_linux_config {
#     disable_password_authentication = false
#   }

#   tags = {
#     environment = "spoke1"
#   }
#   depends_on = [azurerm_network_interface.spoke1_nic]
# }

resource "azurerm_virtual_network_peering" "hub_spoke1_peer" {
  name                         = "hub-spoke1-peer-${random_pet.pet.id}"
  resource_group_name          = azurerm_resource_group.hub_net_rg.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke1_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_virtual_network.spoke1_vnet, azurerm_virtual_network.hub_vnet, azurerm_virtual_network_gateway.hub_vnet_gateway]
}
