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
  description = "SKU of the VPN Gateway (e.g., VpnGw1, VpnGw2, VpnGw1AZ)."
  type        = string
  default     = "VpnGw1"
}

variable "vpn_type" {
  description = "Routing type for the VPN Gateway (RouteBased or PolicyBased)."
  type        = string
  default     = "RouteBased"
}

variable "generation" {
  description = "Generation of the VPN Gateway (Generation1 or Generation2)."
  type        = string
  default     = "Generation2"
}

variable "enable_bgp" {
  description = "Whether BGP is enabled on the VPN Gateway."
  type        = bool
  default     = false
}

variable "local_network_gateways" {
  description = "Map of on-premises / remote VPN site configurations and Site-to-Site connections."
  type = map(object({
    gateway_address = string
    address_space   = list(string)
    shared_key      = string
    connection_type = optional(string, "IPsec")
    routing_weight  = optional(number, 0)
  }))
  default   = {}
  sensitive = true
}

variable "tags" {
  description = "Tags to apply to VPN resources."
  type        = map(string)
  default     = {}
}