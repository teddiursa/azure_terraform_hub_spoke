# Resource Group
resource "azurerm_resource_group" "hub_net_rg" {
  location = var.resource_cloud_group_location
  name     = "hub-net-rg-${random_pet.pet.id}"
}

# Hub network

resource "azurerm_virtual_network" "hub_vnet" {
  name                = "hub-vnet-${random_pet.pet.id}"
  resource_group_name = azurerm_resource_group.hub_net_rg.name
  location            = azurerm_resource_group.hub_net_rg.location
  address_space       = [var.hub_vnet_prefix]

  tags = {
    environment = "hub-spoke"
  }
  depends_on = [azurerm_resource_group.hub_net_rg]
}

resource "time_sleep" "hub_delay" {
  create_duration = "5s"
}

# Name needs to be exactly "GatewaySubnet" for vpn gateway config
resource "azurerm_subnet" "hub_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub_net_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [var.hub_gateway_subnet_prefix]
  depends_on           = [azurerm_virtual_network.hub_vnet]
}

resource "azurerm_subnet" "hub_mgmt" {
  name                 = "mgmt-${random_pet.pet.id}"
  resource_group_name  = azurerm_resource_group.hub_net_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [var.hub_mgmt_subnet_prefix]
  depends_on           = [azurerm_virtual_network.hub_vnet]
}

resource "azurerm_subnet" "hub_dmz" {
  name                 = "dmz-${random_pet.pet.id}"
  resource_group_name  = azurerm_resource_group.hub_net_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [var.hub_dmz_subnet_prefix]
  depends_on           = [azurerm_virtual_network.hub_vnet]
}

# Due to vCPU restrictions, I removed the hub vm

# resource "azurerm_network_interface" "hub_nic" {
#   name                 = "hub-nic"
#   resource_group_name  = azurerm_resource_group.hub_net_rg.name
#   location             = azurerm_resource_group.hub_net_rg.location
#   enable_ip_forwarding = true

#   ip_configuration {
#     name                          = "hub"
#     subnet_id                     = azurerm_subnet.hub_mgmt.id
#     private_ip_address_allocation = "Dynamic"
#   }

#   depends_on = [
#     azurerm_subnet.hub_mgmt,
#     azurerm_resource_group.hub_net_rg,
#   ]

#   tags = {
#     environment = "hub"
#   }
# }

# resource "azurerm_virtual_machine" "hub_vm" {
#   name                  = "hub-vm"
#   resource_group_name   = azurerm_resource_group.hub_net_rg.name
#   location              = azurerm_resource_group.hub_net_rg.location
#   network_interface_ids = [azurerm_network_interface.hub_nic.id]
#   vm_size               = var.vmsize
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
#     computer_name  = "hub-vm"
#     admin_username = "greg"
#     admin_password = var.azure_password
#   }

#   os_profile_linux_config {
#     disable_password_authentication = false
#   }

#   depends_on = [
#     azurerm_network_interface.hub_nic,
#   ]

#   tags = {
#     environment = "hub"
#   }
# }



# Hub Public IP

resource "azurerm_public_ip" "hub_public_ip" {
  name                = "hub-public-ip-${random_pet.pet.id}"
  resource_group_name = azurerm_resource_group.hub_net_rg.name
  location            = azurerm_resource_group.hub_net_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = { environment = "Office pip" }
  depends_on          = [azurerm_resource_group.hub_net_rg]
}

resource "time_sleep" "hub_vpn_delay" {
  create_duration = "3s"
}


resource "azurerm_virtual_network_gateway" "hub_vnet_gateway" {
  name                = "hub-vpn-gateway1-${random_pet.pet.id}"
  resource_group_name = azurerm_resource_group.hub_net_rg.name
  location            = azurerm_resource_group.hub_net_rg.location

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.hub_public_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub_gateway_subnet.id
  }
  depends_on = [azurerm_public_ip.hub_public_ip, azurerm_subnet.hub_gateway_subnet]

}

resource "azurerm_virtual_network_gateway_connection" "hub_office_conn" {
  name                = "hub-office-conn-${random_pet.pet.id}"
  location            = azurerm_resource_group.hub_net_rg.location
  resource_group_name = azurerm_resource_group.hub_net_rg.name

  type           = "Vnet2Vnet"
  routing_weight = 1

  virtual_network_gateway_id      = azurerm_virtual_network_gateway.hub_vnet_gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.office_vpn_gateway.id

  shared_key = var.shared_key

  depends_on = [azurerm_virtual_network_gateway.hub_vnet_gateway, azurerm_virtual_network_gateway.office_vpn_gateway]
}

resource "azurerm_virtual_network_gateway_connection" "office_hub_conn" {
  name                            = "office-hub-conn-${random_pet.pet.id}"
  location                        = azurerm_resource_group.hub_net_rg.location
  resource_group_name             = azurerm_resource_group.hub_net_rg.name
  type                            = "Vnet2Vnet"
  routing_weight                  = 1
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.office_vpn_gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.hub_vnet_gateway.id

  shared_key = var.shared_key

  depends_on = [azurerm_virtual_network_gateway.hub_vnet_gateway, azurerm_virtual_network_gateway.office_vpn_gateway]
}
