# Create the resource group
resource "azurerm_resource_group" "webapp_rg" {
  name     = "cloud-rg-${random_pet.pet.id}"
  location = var.resource_cloud_group_location
}

# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-asp-${random_pet.pet.id}"
  location            = azurerm_resource_group.webapp_rg.location
  resource_group_name = azurerm_resource_group.webapp_rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}


# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp" {
  name                = "webapp-${random_pet.pet.id}"
  location            = azurerm_resource_group.webapp_rg.location
  resource_group_name = azurerm_resource_group.webapp_rg.name
  service_plan_id     = azurerm_service_plan.appserviceplan.id
  # virtual_network_subnet_id     = azurerm_subnet.spoke1_workload.id
  public_network_access_enabled = false
  # https_only                    = false
  site_config {
    # always_on = false
    # # virtual_network_subnet_id = azurerm_subnet.spoke1_workload.id

    # minimum_tls_version = "1.2"
  }
}


# Create a private endpoint
resource "azurerm_private_endpoint" "webapp_private_endpoint" {
  name                = "webapp-endpoint-${random_pet.pet.id}"
  location            = azurerm_resource_group.webapp_rg.location
  resource_group_name = azurerm_resource_group.webapp_rg.name
  subnet_id           = azurerm_subnet.spoke1_workload.id

  private_service_connection {
    name                           = "webapp-privateserviceconnection" # ${random_pet.pet.id}
    is_manual_connection           = false
    private_connection_resource_id = azurerm_linux_web_app.webapp.id
    subresource_names              = ["sites"]
  }
}

# Create a Private DNS Zone
resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.webapp_rg.name
}

# Link the Private DNS Zone to the Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "webapp_link" {
  name                  = "webapp-link-${random_pet.pet.id}"
  resource_group_name   = azurerm_resource_group.webapp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = azurerm_virtual_network.spoke1_vnet.id
}

# Create a DNS 'A' Record
resource "azurerm_private_dns_a_record" "webapp_A_record" {
  name                = "webapp-a-${random_pet.pet.id}"
  zone_name           = azurerm_private_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.webapp_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.webapp_private_endpoint.private_service_connection.0.private_ip_address]
}
