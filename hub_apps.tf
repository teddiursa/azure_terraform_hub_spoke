# Resource Group
resource "azurerm_resource_group" "hub_apps_rg" {
  location = var.resource_group_location
  name     = "hub-apps-rg"
}

resource "azurerm_network_interface" "hub_nva_nic" {
  name                 = "hub-nva-nic"
  resource_group_name  = azurerm_resource_group.hub_apps_rg.name
  location             = azurerm_resource_group.hub_apps_rg.location
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "hub-nva"
    subnet_id                     = azurerm_subnet.hub_dmz.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.36"
  }

  depends_on = [
    azurerm_subnet.hub_dmz,
    azurerm_resource_group.hub_apps_rg,
  ]

  tags = {
    environment = "hub-nva"
  }
}

resource "azurerm_virtual_machine" "hub_nva_vm" {
  name                             = "hub-nva-vm"
  resource_group_name              = azurerm_resource_group.hub_apps_rg.name
  location                         = azurerm_resource_group.hub_apps_rg.location
  network_interface_ids            = [azurerm_network_interface.hub_nva_nic.id]
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
    computer_name  = "hub-nva-vm"
    admin_username = "greg"
    admin_password = var.azure_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "hub-nva"
  }
}

resource "azurerm_virtual_machine_extension" "enable_routes" {
  name                 = "enable-ip-forwarding"
  virtual_machine_id   = azurerm_virtual_machine.hub_nva_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
      "commandToExecute": "echo 1 > /proc/sys/net/ipv4/ip_forward"
    }
  SETTINGS

  tags = {
    environment = "hub-nva"
  }
}

resource "azurerm_route_table" "hub_gateway_rt" {
  name                          = "hub-gateway-rt"
  resource_group_name           = azurerm_resource_group.hub_apps_rg.name
  location                      = azurerm_resource_group.hub_apps_rg.location
  disable_bgp_route_propagation = false

  route {
    name           = "toHub"
    address_prefix = "10.0.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  route {
    name                   = "toSpoke1"
    address_prefix         = "10.1.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.36"
  }

  route {
    name                   = "toSpoke2"
    address_prefix         = "10.2.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.36"
  }

  tags = {
    environment = "hub-nva"
  }
}

resource "azurerm_subnet_route_table_association" "hub_gateway_rt_hub_vnet_gateway_subnet" {
  subnet_id      = azurerm_subnet.hub_gateway_subnet.id
  route_table_id = azurerm_route_table.hub_gateway_rt.id
  depends_on     = [azurerm_subnet.hub_gateway_subnet, azurerm_route_table.hub_gateway_rt]
}

resource "azurerm_route_table" "spoke1_rt" {
  name                          = "spoke1-rt"
  resource_group_name           = azurerm_resource_group.hub_apps_rg.name
  location                      = azurerm_resource_group.hub_apps_rg.location
  disable_bgp_route_propagation = false

  route {
    name                   = "toSpoke2"
    address_prefix         = "10.2.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.36"
  }

  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VnetLocal"
  }

  tags = {
    environment = "hub-nva"
  }
}

resource "azurerm_subnet_route_table_association" "spoke1_rt_spoke1_vnet_mgmt" {
  subnet_id      = azurerm_subnet.spoke1_mgmt.id
  route_table_id = azurerm_route_table.spoke1_rt.id
  depends_on     = [azurerm_subnet.spoke1_mgmt]
}

resource "azurerm_subnet_route_table_association" "spoke1_rt_spoke1_vnet_workload" {
  subnet_id      = azurerm_subnet.spoke1_workload.id
  route_table_id = azurerm_route_table.spoke1_rt.id
  depends_on     = [azurerm_subnet.spoke1_workload]
}

resource "azurerm_route_table" "spoke2_rt" {
  name                          = "spoke2-rt"
  location                      = azurerm_resource_group.hub_apps_rg.location
  resource_group_name           = azurerm_resource_group.hub_apps_rg.name
  disable_bgp_route_propagation = false

  route {
    name                   = "toSpoke1"
    address_prefix         = "10.1.0.0/16"
    next_hop_in_ip_address = "10.0.0.36"
    next_hop_type          = "VirtualAppliance"
  }

  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VnetLocal"
  }

  tags = {
    environment = "hub-nva"
  }
}

resource "azurerm_subnet_route_table_association" "spoke2_rt_spoke2_vnet_mgmt" {
  subnet_id      = azurerm_subnet.spoke2_mgmt.id
  route_table_id = azurerm_route_table.spoke2_rt.id
  depends_on     = [azurerm_subnet.spoke2_mgmt]
}

resource "azurerm_subnet_route_table_association" "spoke2_rt_spoke2_vnet_workload" {
  subnet_id      = azurerm_subnet.spoke2_workload.id
  route_table_id = azurerm_route_table.spoke2_rt.id
  depends_on     = [azurerm_subnet.spoke2_workload]
}
