# Metric categories per resource type found here: https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-logs/logs-index
# or via CLI: az monitor diagnostic-settings categories list --resource <resource id>

resource "azurerm_resource_group" "log_rg" {
  name     = "log-rg-${random_pet.pet.id}"
  location = var.resource_cloud_group_location
}

# Log storage account
# Name requirements need to be alpha-numeric and 3-24 chars

resource "random_integer" "random_int" {
  min = 1
  max = 99999

}

resource "azurerm_storage_account" "log_storage" {
  name                     = "logstorage${random_integer.random_int.result}"
  resource_group_name      = azurerm_resource_group.log_rg.name
  location                 = azurerm_resource_group.log_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_log_analytics_workspace" "log_workspace" {
  name                = "log-workspace-${random_pet.pet.id}"
  resource_group_name = azurerm_resource_group.log_rg.name
  location            = azurerm_resource_group.log_rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "office_vpn_log" {
  name                       = "office-vpn-log-${random_pet.pet.id}"
  target_resource_id         = azurerm_virtual_network_gateway.office_vpn_gateway.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
  storage_account_id = azurerm_storage_account.log_storage.id

  enabled_log {
    category = "GatewayDiagnosticLog"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "hub_vpn_log" {
  name                       = "hub-vpn-log-${random_pet.pet.id}"
  target_resource_id         = azurerm_virtual_network_gateway.hub_vnet_gateway.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
  storage_account_id = azurerm_storage_account.log_storage.id

  enabled_log {
    category = "GatewayDiagnosticLog"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "office_mgmt_nsg_log" {
  name                       = "office-mgmt-nsg-log-${random_pet.pet.id}"
  target_resource_id         = azurerm_network_security_group.office_mgmt_nsg.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
  storage_account_id = azurerm_storage_account.log_storage.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

}

resource "azurerm_monitor_diagnostic_setting" "spoke1_nsg_log" {
  name                       = "spoke1-nsg-log-${random_pet.pet.id}"
  target_resource_id         = azurerm_network_security_group.spoke1_nsg.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
  storage_account_id = azurerm_storage_account.log_storage.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

}

resource "azurerm_monitor_diagnostic_setting" "spoke2_nsg_log" {
  name                       = "spoke2-nsg-log-${random_pet.pet.id}"
  target_resource_id         = azurerm_network_security_group.spoke2_nsg.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
  storage_account_id = azurerm_storage_account.log_storage.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

}

resource "azurerm_monitor_diagnostic_setting" "webapp1_log" {
  name                       = "webapp1-log-${random_pet.pet.id}"
  target_resource_id         = azurerm_linux_web_app.webapp1.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
  storage_account_id = azurerm_storage_account.log_storage.id

  enabled_log {
    category = "AppServiceAppLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "webapp2_log" {
  name                       = "webapp2-log-${random_pet.pet.id}"
  target_resource_id         = azurerm_linux_web_app.webapp2.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
  storage_account_id = azurerm_storage_account.log_storage.id

  enabled_log {
    category = "AppServiceAppLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "sqlserver_log" {
  name                       = "sqlserver-log-${random_pet.pet.id}"
  target_resource_id         = azurerm_mssql_server.sqlserver.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
  storage_account_id = azurerm_storage_account.log_storage.id

  metric {
    category = "AllMetrics"
  }
}


# Net watcher

# resource "azurerm_network_watcher" "log_watcher" {
#   name                = "log-watcher-${random_pet.pet.id}"
#   resource_group_name = azurerm_resource_group.log_rg.name
#   location            = azurerm_resource_group.log_rg.location
# }

# # Netflow logs for spoke1 NSG
# resource "azurerm_network_watcher_flow_log" "spoke1_nsg_flosws" {
#   name                 = "spoke1-nsg-flow-${random_pet.pet.id}"
#   network_watcher_name = azurerm_network_watcher.log_watcher.name
#   resource_group_name  = azurerm_resource_group.log_rg.name

#   network_security_group_id = azurerm_network_security_group.spoke1_nsg.id
#   storage_account_id        = azurerm_storage_account.log_storage.id
#   enabled                   = true

#   retention_policy {
#     enabled = true
#     days    = 7
#   }

#   traffic_analytics {
#     enabled               = true
#     workspace_id          = azurerm_log_analytics_workspace.log_workspace.workspace_id
#     workspace_region      = azurerm_log_analytics_workspace.log_workspace.location
#     workspace_resource_id = azurerm_log_analytics_workspace.log_workspace.id
#   }
# }

# Net Flow logs 
