resource "azurerm_resource_group" "office_rg" {
  location = var.resource_office_group_location
  name     = "office-rg-${random_pet.pet.id}"
}

resource "azurerm_virtual_network" "office_network" {
  name                = "main-office-vnet-${random_pet.pet.id}"
  address_space       = [var.office_vnet_prefix]
  location            = azurerm_resource_group.office_rg.location
  resource_group_name = azurerm_resource_group.office_rg.name
  depends_on          = [azurerm_resource_group.office_rg]
}




# Gateway Subnet
# Name needs to be exactly "GatewaySubnet" for vpn gateway config
resource "azurerm_subnet" "office_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.office_rg.name
  virtual_network_name = azurerm_virtual_network.office_network.name
  address_prefixes     = [var.office_gateway_subnet_prefix]
  depends_on           = [azurerm_virtual_network.office_network,azurerm_resource_group.office_rg]
}

# Subnet 2
resource "azurerm_subnet" "office_mgmt_subnet" {
  name                 = "office-mgmt-subnet-${random_pet.pet.id}"
  resource_group_name  = azurerm_resource_group.office_rg.name
  virtual_network_name = azurerm_virtual_network.office_network.name
  address_prefixes     = [var.office_mgmt_subnet_prefix]
  depends_on           = [azurerm_virtual_network.office_network,azurerm_resource_group.office_rg]
}

# Subnet 3
resource "azurerm_subnet" "office_user_subnet" {
  name                 = "office-user-subnet-${random_pet.pet.id}"
  resource_group_name  = azurerm_resource_group.office_rg.name
  virtual_network_name = azurerm_virtual_network.office_network.name
  address_prefixes     = [var.office_user_subnet_prefix]
  depends_on           = [azurerm_virtual_network.office_network,azurerm_resource_group.office_rg]
}

# Public IP and office nic is for the "on-prem" vm I remote into
resource "azurerm_public_ip" "office_vm_public_ip" {
  name                = "office-vm-public-ip-${random_pet.pet.id}"
  resource_group_name = azurerm_resource_group.office_rg.name
  location            = azurerm_resource_group.office_rg.location
  allocation_method   = "Dynamic"
  tags                = { environment = "Office VM public ip" }
  depends_on          = [azurerm_virtual_network.office_network]
}


resource "azurerm_network_interface" "office_nic_1" {
  name                = "office-nic-1-${random_pet.pet.id}"
  location            = azurerm_resource_group.office_rg.location
  resource_group_name = azurerm_resource_group.office_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.office_mgmt_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.office_vm_public_ip.id
  }
  depends_on = [azurerm_public_ip.office_vm_public_ip, azurerm_subnet.office_mgmt_subnet]
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "office_mgmt_nsg" {
  name                = "office-mgmt-nsg-${random_pet.pet.id}"
  location            = azurerm_resource_group.office_rg.location
  resource_group_name = azurerm_resource_group.office_rg.name

  # Allow SSH into vm from only my home public IP
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.home_public_ip
    destination_address_prefix = "*"
  }

  tags = {
    environment = "office"
  }
  depends_on = [azurerm_resource_group.office_rg]
}

resource "azurerm_subnet_network_security_group_association" "office_mgmt_nsg_association" {
  subnet_id                 = azurerm_subnet.office_mgmt_subnet.id
  network_security_group_id = azurerm_network_security_group.office_mgmt_nsg.id
  depends_on                = [azurerm_subnet.office_mgmt_subnet, azurerm_network_security_group.office_mgmt_nsg]
}

resource "azurerm_virtual_machine" "office_vm_1" {
  name                          = "office-vm-${random_pet.pet.id}"
  resource_group_name           = azurerm_resource_group.office_rg.name
  location                      = azurerm_resource_group.office_rg.location
  network_interface_ids         = [azurerm_network_interface.office_nic_1.id]
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
    computer_name  = "office-vm-1"
    admin_username = var.azure_user
    admin_password = var.azure_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "office"
  }
  depends_on = [azurerm_network_interface.office_nic_1]
}

# Public IP

resource "azurerm_public_ip" "office_public_ip" {
  name                = "office-public-ip-${random_pet.pet.id}"
  resource_group_name = azurerm_resource_group.office_rg.name
  location            = azurerm_resource_group.office_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = { environment = "Office public ip" }
  depends_on          = [azurerm_resource_group.office_rg]
}


# VPN gateway to connect to "hub" network
resource "azurerm_virtual_network_gateway" "office_vpn_gateway" {
  name                = "office-vpn-gateway1-${random_pet.pet.id}"
  resource_group_name = azurerm_resource_group.office_rg.name
  location            = azurerm_resource_group.office_rg.location

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.office_public_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.office_gateway_subnet.id
  }
  depends_on = [azurerm_public_ip.office_public_ip, azurerm_subnet.office_gateway_subnet]
}
