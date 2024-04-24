resource "azurerm_resource_group" "webapp_rg" {
  name     = "webapp-rg-${random_pet.pet.id}"
  location = var.resource_cloud_group_location
}

resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-asp-${random_pet.pet.id}"
  location            = azurerm_resource_group.webapp_rg.location
  resource_group_name = azurerm_resource_group.webapp_rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "webapp1" {
  name                          = "webapp1-${random_pet.pet.id}"
  location                      = azurerm_resource_group.webapp_rg.location
  resource_group_name           = azurerm_resource_group.webapp_rg.name
  service_plan_id               = azurerm_service_plan.appserviceplan.id
  public_network_access_enabled = false
  # https_only                    = false
  site_config {
    # always_on = false
    # # virtual_network_subnet_id = azurerm_subnet.spoke1_workload.id

    # minimum_tls_version = "1.2"
  }
}


resource "azurerm_linux_web_app" "webapp2" {
  name                          = "webapp2-${random_pet.pet.id}"
  location                      = azurerm_resource_group.webapp_rg.location
  resource_group_name           = azurerm_resource_group.webapp_rg.name
  service_plan_id               = azurerm_service_plan.appserviceplan.id
  public_network_access_enabled = false
  # https_only                    = false
  site_config {
    # always_on = false
    # # virtual_network_subnet_id = azurerm_subnet.spoke1_workload.id

    # minimum_tls_version = "1.2"
  }
}

# Create a private endpoint for webapp1 in spoke1_workload subnet
resource "azurerm_private_endpoint" "webapp1_private_endpoint" {
  name                = "webapp1-endpoint-${random_pet.pet.id}"
  location            = azurerm_resource_group.webapp_rg.location
  resource_group_name = azurerm_resource_group.webapp_rg.name
  subnet_id           = azurerm_subnet.spoke1_workload.id

  private_service_connection {
    name                           = "webapp1-privateserviceconnection-${random_pet.pet.id}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_linux_web_app.webapp1.id
    subresource_names              = ["sites"]
  }
}

# Create a private endpoint for webapp2 in spoke1_workload subnet
resource "azurerm_private_endpoint" "webapp2_private_endpoint" {
  name                = "webapp2-endpoint-${random_pet.pet.id}"
  location            = azurerm_resource_group.webapp_rg.location
  resource_group_name = azurerm_resource_group.webapp_rg.name
  subnet_id           = azurerm_subnet.spoke1_workload.id

  private_service_connection {
    name                           = "webapp2-privateserviceconnection-${random_pet.pet.id}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_linux_web_app.webapp2.id
    subresource_names              = ["sites"]
  }
}

# resource "time_sleep" "txt_record_delay" {
#   create_duration = "60s"
# }

# resource "azurerm_app_service_custom_hostname_binding" "webapp1_binding" {
#   hostname            = "${azurerm_linux_web_app.webapp1.name}.${var.domain_name}"
#   app_service_name    = azurerm_linux_web_app.webapp1.name
#   resource_group_name = azurerm_resource_group.webapp_rg.name
#   depends_on          = [time_sleep.txt_record_delay, azurerm_dns_txt_record.webapp1_txt_record]
# }

# resource "azurerm_app_service_custom_hostname_binding" "webapp2_binding" {
#   hostname            = "${azurerm_linux_web_app.webapp2.name}.${var.domain_name}"
#   app_service_name    = azurerm_linux_web_app.webapp2.name
#   resource_group_name = azurerm_resource_group.webapp_rg.name
#   depends_on          = [time_sleep.txt_record_delay, azurerm_dns_txt_record.webapp2_txt_record]
# }

# Application gateway
# Not using due to regional public ip limit

# resource "azurerm_public_ip" "gateway_pip" {
#   name                = "gw-pip"
#   location            = azurerm_resource_group.webapp_rg.location
#   resource_group_name = azurerm_resource_group.webapp_rg.name
#   allocation_method   = "Dynamic"
# }
# # Create an Application Gateway
# resource "azurerm_application_gateway" "appgw" {
#   name                = "appgw"
#   location            = azurerm_resource_group.webapp_rg.location
#   resource_group_name = azurerm_resource_group.webapp_rg.name

#   sku {
#     # name     = "Standard_Medium"
#     # tier     = "Standard"
#     name     = "Standard_v2"
#     tier     = "Standard_v2"
#     capacity = 2
#   }

#   gateway_ip_configuration {
#     name      = "gateway-ip-configuration"
#     subnet_id = azurerm_subnet.spoke1_workload.id
#   }

#   frontend_port {
#     name = "http-port"
#     port = 80
#   }

#   frontend_ip_configuration {
#     name                          = "spoke1-ip"
#     private_ip_address_allocation = "Dynamic"
#     subnet_id                     = azurerm_subnet.spoke1_workload.id
#     public_ip_address_id = azurerm_public_ip.gateway_pip.id

#   }

#   # Backend Address Pool
#   backend_address_pool {
#     name  = "webapp-backend-pool"
#     fqdns = ["webapp1.azurewebsites.net", "webapp2.azurewebsites.net"]
#   }

#   # Backend HTTP Settings
#   backend_http_settings {
#     name                                = "webapp-backend-http-settings"
#     cookie_based_affinity               = "Disabled"
#     port                                = 80
#     protocol                            = "Http"
#     request_timeout                     = 60
#     pick_host_name_from_backend_address = true
#   }

#   # HTTP Listener
#   http_listener {
#     name                           = "webapp-http-listener"
#     protocol                       = "Http"
#     frontend_ip_configuration_name = "spoke1-ip"
#     frontend_port_name             = "http-port"
#   }

#   # Request Routing Rule
#   request_routing_rule {
#     name                       = "webapp-request-routing-rule"
#     rule_type                  = "Basic"
#     http_listener_name         = "webapp-http-listener"
#     backend_address_pool_name  = "webapp-backend-pool"
#     backend_http_settings_name = "webapp-backend-http-settings"
#     priority                   = 1
#   }
# }
