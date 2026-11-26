variable "name" {
  description = "Name of the Azure Virtual Network Gateway (VPN)."
  type        = string
}

variable "location" {
  description = "Azure region for the VPN Gateway and Public IP."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where VPN resources will be created."
  type        = string
}

variable "gateway_subnet_id" {
  description = "Subnet ID of the GatewaySubnet in the Hub Virtual Network."
  type        = string
}

variable "sku" {
  description = "SKU of the VPN Gateway. VpnGw1AZ is the lowest tier recommended for new deployments."
  type        = string
  default     = "VpnGw1AZ"
}

variable "vpn_type" {
  description = "Routing type for the VPN Gateway (RouteBased or PolicyBased)."
  type        = string
  default     = "RouteBased"
}

variable "generation" {
  description = "Generation of the VPN Gateway (Generation1 or Generation2)."
  type        = string
  default     = "Generation1"
}

variable "enable_bgp" {
  description = "Whether BGP is enabled on the VPN Gateway."
  type        = bool
  default     = false
}

variable "local_network_gateways" {
  description = "List of on-premises / remote VPN site configurations and Site-to-Site connections."
  type = list(object({
    name            = string
    gateway_address = string
    address_space   = list(string)
    shared_key      = string
    connection_type = optional(string, "IPsec")
    routing_weight  = optional(number, 0)
  }))
  default   = []
  sensitive = true
}

variable "p2s" {
  description = "Optional Point-to-Site (P2S) VPN configuration using Microsoft Entra ID (no root certificate required)."
  type = object({
    enabled       = optional(bool, false)
    address_space = list(string)
    aad_tenant_id = string
    aad_audience  = optional(string, "c632b3df-fb67-4d84-bdcf-b95ad541b5c8")
    aad_issuer    = optional(string)
    protocols     = optional(list(string), ["OpenVPN"])
  })
  default = null
}

variable "tags" {
  description = "Tags to apply to VPN resources."
  type        = map(string)
  default     = {}
}