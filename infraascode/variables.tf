###############################################################################
# Input Variables - Connectivity Hub
###############################################################################

variable "environment" {
  description = "Target deployment environment (e.g., dev, test, stage, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "development", "test", "stage", "staging", "nonprod", "prod", "production", "demo"], lower(var.environment))
    error_message = "The environment variable must be a recognized tier (e.g., dev, test, staging, prod, demo)."
  }
}

variable "location" {
  description = "Azure region where the Connectivity Hub resources will be provisioned."
  type        = string
  default     = "centralus"
}

variable "enable_telemetry" {
  description = "Enable Azure Verified Module (AVM) telemetry via modtm."
  type        = bool
  default     = false
}

variable "hub_vnet_name" {
  description = "Name of the centralized Hub Virtual Network."
  type        = string
  default     = "vnet-platform-connectivity"
}

variable "hub_vnet_cidr" {
  description = "Address space for the centralized Hub Virtual Network in CIDR notation."
  type        = string
  default     = "10.0.0.0/16"
}

variable "hub_shared_subnet_cidr" {
  description = "Address prefix for the Hub shared services/management subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "resource_group_name" {
  description = "Custom name for the Hub resource group. If omitted, a standard name with random suffix will be generated."
  type        = string
  default     = ""
}

variable "dns_resource_group_name" {
  description = "Custom name for the resource group hosting DNS resources. If omitted, a name is generated from the workload, environment, region, and instance."
  type        = string
  default     = ""
}

variable "custom_tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "hub_vpn_configs" {
  description = "Map of VPN configurations keyed by Hub VNet key (e.g., primary)."
  type = map(object({
    enabled    = optional(bool, false)
    name       = optional(string)
    sku        = optional(string, "VpnGw1AZ")
    vpn_type   = optional(string, "RouteBased")
    generation = optional(string, "Generation1")
    enable_bgp = optional(bool, false)
    sites = optional(list(object({
      name            = string
      gateway_address = string
      address_space   = list(string)
      shared_key      = string
      connection_type = optional(string, "IPsec")
      routing_weight  = optional(number, 0)
    })), [])
    p2s = optional(object({
      enabled       = optional(bool, false)
      address_space = list(string)
      aad_tenant_id = string
      aad_audience  = optional(string, "c632b3df-fb67-4d84-bdcf-b95ad541b5c8")
      aad_issuer    = optional(string)
      protocols     = optional(list(string), ["OpenVPN"])
    }))
  }))
  default   = {}
  sensitive = true
}

variable "hub_dns_resolver_configs" {
  description = "Map of Azure DNS Private Resolver configurations keyed by Hub VNet key (e.g., primary)."
  type = map(object({
    enabled                              = optional(bool, false)
    name                                 = optional(string)
    inbound_endpoint_name                = optional(string, "in-ep-default")
    inbound_private_ip_allocation_method = optional(string, "Dynamic")
    inbound_private_ip_address           = optional(string)
  }))
  default = {}
}