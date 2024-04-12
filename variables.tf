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

variable "resource_group_location" {
  type        = string
  default     = "westus"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}


