variable "name" {
  description = "Name of the Azure DNS Private Resolver."
  type        = string
}

variable "location" {
  description = "Azure region for the DNS Private Resolver."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where the DNS Private Resolver will be deployed."
  type        = string
}

variable "virtual_network_id" {
  description = "Resource ID of the Hub Virtual Network."
  type        = string
}

variable "inbound_endpoint_name" {
  description = "Name of the Inbound Endpoint."
  type        = string
  default     = "in-ep-default"
}

variable "inbound_subnet_id" {
  description = "Resource ID of the delegated subnet (Microsoft.Network/dnsResolvers) for the Inbound Endpoint."
  type        = string
}

variable "inbound_private_ip_allocation_method" {
  description = "Private IP allocation method for the Inbound Endpoint (Dynamic or Static)."
  type        = string
  default     = "Dynamic"

  validation {
    condition     = contains(["Dynamic", "Static"], var.inbound_private_ip_allocation_method)
    error_message = "inbound_private_ip_allocation_method must be either Dynamic or Static."
  }
}

variable "inbound_private_ip_address" {
  description = "Static private IP address for the Inbound Endpoint (required if allocation method is Static)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the DNS Private Resolver resources."
  type        = map(string)
  default     = {}
}