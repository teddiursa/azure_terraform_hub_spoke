# Resource Group
resource "azurerm_resource_group" "spoke1_rg" {
  location = var.resource_group_location
  name     = "spoke1-rg"
}

resource "azurerm_virtual_network" "spoke1_vnet" {
  name                = "spoke1-vnet"
  resource_group_name = azurerm_resource_group.spoke1_rg.name
  location            = azurerm_resource_group.spoke1_rg.location
  address_space       = ["10.1.0.0/16"]

  tags = {
    environment = "spoke1"
  }
}

resource "azurerm_subnet" "spoke1_mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.spoke1_rg.name
  virtual_network_name = azurerm_virtual_network.spoke1_vnet.name
  address_prefixes     = ["10.1.0.64/27"]
}

resource "azurerm_subnet" "spoke1_workload" {
  name                 = "workload"
  resource_group_name  = azurerm_resource_group.spoke1_rg.name
  virtual_network_name = azurerm_virtual_network.spoke1_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_virtual_network_peering" "spoke1_hub_peer" {
  name                      = "spoke1-hub-peer"
  resource_group_name       = azurerm_resource_group.spoke1_rg.name
  virtual_network_name      = azurerm_virtual_network.spoke1_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
  depends_on                   = [azurerm_virtual_network.spoke1_vnet, azurerm_virtual_network.hub_vnet, azurerm_virtual_network_gateway.hub_vnet_gateway]
}

resource "azurerm_network_interface" "spoke1_nic" {
  name                 = "spoke1-vm-nic"
  resource_group_name  = azurerm_resource_group.spoke1_rg.name
  location             = azurerm_resource_group.spoke1_rg.location
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "spoke1-vm"
    subnet_id                     = azurerm_subnet.spoke1_mgmt.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "spoke1_vm" {
  name                             = "spoke1-vm"
  resource_group_name              = azurerm_resource_group.spoke1_rg.name
  location                         = azurerm_resource_group.spoke1_rg.location
  network_interface_ids            = [azurerm_network_interface.spoke1_nic.id]
  vm_size                          = var.vmsize
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
    computer_name  = "spoke1-vm"
    admin_username = "greg"
    admin_password = var.azure_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "spoke1"
  }
}

resource "azurerm_virtual_network_peering" "hub_spoke1_peer" {
  name                         = "hub-spoke1-peer"
  resource_group_name          = azurerm_resource_group.hub_net_rg.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke1_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_virtual_network.spoke1_vnet, azurerm_virtual_network.hub_vnet, azurerm_virtual_network_gateway.hub_vnet_gateway]
}
