resource "azurerm_resource_group" "webapp_rg" {
  name     = "cloud-rg-${random_pet.pet.id}"
  location = var.resource_cloud_group_location
}

resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-asp-${random_pet.pet.id}"
  location            = azurerm_resource_group.webapp_rg.location
  resource_group_name = azurerm_resource_group.webapp_rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}


resource "azurerm_linux_web_app" "webapp" {
  name                = "webapp-${random_pet.pet.id}"
  location            = azurerm_resource_group.webapp_rg.location
  resource_group_name = azurerm_resource_group.webapp_rg.name
  service_plan_id     = azurerm_service_plan.appserviceplan.id
  public_network_access_enabled = false
  # https_only                    = false
  site_config {
    # always_on = false
    # # virtual_network_subnet_id = azurerm_subnet.spoke1_workload.id

    # minimum_tls_version = "1.2"
  }
}

# Create a private endpoint for webapp in spoke1_workload subnet
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
