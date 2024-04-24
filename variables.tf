# Sensitive variables stored in secret.tfvars
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Azure client ID"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Azure client secret"
  type        = string
  sensitive   = true
}

variable "azure_password" {
  description = "Password for Azure resources"
  type        = string
  sensitive   = true
}

variable "azure_user" {
  description = "Username for Azure resources"
  type        = string
  sensitive   = true
}

variable "home_public_ip" {
  description = "Public IP of my home"
  type        = string
  sensitive   = true
}

variable "shared_key" {
  description = "Public IP of my home"
  type        = string
  sensitive   = true
}

variable "vmsize" {
  description = "Size of the VMs"
  default     = "Standard_DS1_v2"
}

variable "resource_office_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_cloud_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "domain_name" {
  type        = string
  description = "Domain name"
}

# variable "resource_group_name_prefix" {
#   type        = string
#   default     = "rg"
#   description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
# }


# Office network address space

variable "office_vnet_prefix" {
  description = "Address prefix for the office vnet"
  type        = string
  default     = "192.168.0.0/16"
}

variable "office_gateway_subnet_prefix" {
  description = "Address prefix for the office GatewaySubnet"
  type        = string
  default     = "192.168.255.224/27"
}

variable "office_mgmt_subnet_prefix" {
  description = "Address prefix for the office mgmt subnet"
  type        = string
  default     = "192.168.1.128/25"
}

variable "office_user_subnet_prefix" {
  description = "Address prefix for the office user subnet"
  type        = string
  default     = "192.168.10.0/24"
}

# Hub network address space

variable "hub_vnet_prefix" {
  description = "Address prefix for the hub vnet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "hub_gateway_subnet_prefix" {
  description = "Address prefix for the hub GatewaySubnet"
  type        = string
  default     = "10.0.255.224/27"
}

variable "hub_mgmt_subnet_prefix" {
  description = "Address prefix for the hub mgmt subnet"
  type        = string
  default     = "10.0.0.64/27"
}

variable "hub_dmz_subnet_prefix" {
  description = "Address prefix for the dmz subnet"
  type        = string
  default     = "10.0.0.32/27"
}

variable "hub_nva_ip" {
  description = "Address for hub-nva-nic"
  type        = string
  default     = "10.0.0.36"
}

# Spoke1 network address space

variable "spoke1_vnet_prefix" {
  description = "Address prefix for the spoke1 vnet"
  type        = string
  default     = "10.1.0.0/16"
}

variable "spoke1_mgmt_subnet_prefix" {
  description = "Address prefix for the spoke1 management subnet"
  type        = string
  default     = "10.1.0.64/27"
}

variable "spoke1_workload_subnet_prefix" {
  description = "Address prefix for the spoke1 workload subnet"
  type        = string
  default     = "10.1.1.0/24"
}


# Spoke2 network address space

variable "spoke2_vnet_prefix" {
  description = "Address prefix for the spoke2 vnet"
  type        = string
  default     = "10.2.0.0/16"
}

variable "spoke2_mgmt_subnet_prefix" {
  description = "Address prefix for the spoke2 management subnet"
  type        = string
  default     = "10.2.0.64/27"
}

variable "spoke2_workload_subnet_prefix" {
  description = "Address prefix for the spoke2 workload subnet"
  type        = string
  default     = "10.2.1.0/24"
}
