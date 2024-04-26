# Resource Group
resource "azurerm_resource_group" "spoke2_rg" {
  location = var.resource_cloud_group_location
  name     = "spoke2-rg-${random_pet.pet.id}"
}

resource "azurerm_virtual_network" "spoke2_vnet" {
  name                = "spoke2-vnet-${random_pet.pet.id}"
  resource_group_name = azurerm_resource_group.spoke2_rg.name
  location            = azurerm_resource_group.spoke2_rg.location
  address_space       = [var.spoke2_vnet_prefix]

  tags = {
    environment = "spoke2"
  }
  depends_on = [azurerm_resource_group.spoke2_rg]
}

resource "azurerm_subnet" "spoke2_mgmt" {
  name                 = "mgmt-${random_pet.pet.id}"
  resource_group_name  = azurerm_resource_group.spoke2_rg.name
  virtual_network_name = azurerm_virtual_network.spoke2_vnet.name
  address_prefixes     = [var.spoke2_mgmt_subnet_prefix]
  depends_on           = [azurerm_virtual_network.spoke2_vnet]
}

resource "azurerm_subnet" "spoke2_workload" {
  name                 = "workload-${random_pet.pet.id}"
  resource_group_name  = azurerm_resource_group.spoke2_rg.name
  virtual_network_name = azurerm_virtual_network.spoke2_vnet.name
  address_prefixes     = [var.spoke2_workload_subnet_prefix]
  depends_on           = [azurerm_virtual_network.spoke2_vnet]
}

# NSGs

resource "azurerm_network_security_group" "spoke2_nsg" {
  name                = "spoke2-nsg-${random_pet.pet.id}"
  resource_group_name = azurerm_resource_group.spoke2_rg.name
  location            = azurerm_resource_group.spoke2_rg.location
}

# Allow SQL traffic to workload subnet from mgmt subnet

resource "azurerm_network_security_rule" "sql_rule" {
  name                        = "AllowSQL"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = var.office_mgmt_subnet_prefix
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.spoke2_rg.name
  network_security_group_name = azurerm_network_security_group.spoke2_nsg.name
}

resource "azurerm_network_security_rule" "block_sql_rule" {
  name                        = "DenySQL"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.spoke2_rg.name
  network_security_group_name = azurerm_network_security_group.spoke2_nsg.name
}

resource "azurerm_network_security_rule" "spoke2_ssh_rule" {
  name                        = "AllowSSH"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = [var.office_mgmt_subnet_prefix, var.bastion_subnet_prefix]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.spoke2_rg.name
  network_security_group_name = azurerm_network_security_group.spoke2_nsg.name
}

resource "azurerm_network_security_rule" "spoke2_block_ssh_rule" {
  name                        = "DenySSH"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.spoke2_rg.name
  network_security_group_name = azurerm_network_security_group.spoke2_nsg.name
}


resource "azurerm_subnet_network_security_group_association" "spoke2_workload_nsg_assoc" {
  subnet_id                 = azurerm_subnet.spoke2_workload.id
  network_security_group_id = azurerm_network_security_group.spoke2_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "spoke2_mgmt_nsg_assoc" {
  subnet_id                 = azurerm_subnet.spoke2_mgmt.id
  network_security_group_id = azurerm_network_security_group.spoke2_nsg.id
}

resource "azurerm_virtual_network_peering" "spoke2_hub_peer" {
  name                      = "spoke2-hub-peer-${random_pet.pet.id}"
  resource_group_name       = azurerm_resource_group.spoke2_rg.name
  virtual_network_name      = azurerm_virtual_network.spoke2_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
  depends_on                   = [azurerm_virtual_network.spoke2_vnet, azurerm_virtual_network.hub_vnet, azurerm_virtual_network_gateway.hub_vnet_gateway]
}

resource "azurerm_network_interface" "spoke2_nic" {
  name                 = "spoke2-vm-nic-${random_pet.pet.id}"
  resource_group_name  = azurerm_resource_group.spoke2_rg.name
  location             = azurerm_resource_group.spoke2_rg.location
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "spoke2-vm"
    subnet_id                     = azurerm_subnet.spoke2_mgmt.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [azurerm_subnet.spoke2_mgmt]
}

resource "azurerm_virtual_machine" "spoke2_vm" {
  name                          = "spoke2-vm-${random_pet.pet.id}"
  resource_group_name           = azurerm_resource_group.spoke2_rg.name
  location                      = azurerm_resource_group.spoke2_rg.location
  network_interface_ids         = [azurerm_network_interface.spoke2_nic.id]
  vm_size                       = var.vmsize
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "spoke2-vm"
    admin_username = var.azure_user
    admin_password = var.azure_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "spoke2"
  }
  depends_on = [azurerm_network_interface.spoke2_nic]
}

resource "azurerm_virtual_network_peering" "hub_spoke2_peer" {
  name                         = "hub-spoke2-peer-${random_pet.pet.id}"
  resource_group_name          = azurerm_resource_group.hub_net_rg.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke2_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_virtual_network.spoke2_vnet, azurerm_virtual_network.hub_vnet, azurerm_virtual_network_gateway.hub_vnet_gateway]
}
