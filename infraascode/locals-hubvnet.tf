locals {
  hub_vnets = {
    "primary" = {
      name          = var.hub_vnet_name
      location      = local.location
      address_space = ["10.0.0.0/16"]

      subnets = {
        default = {
          name             = "snet-default"
          address_prefixes = ["10.0.1.0/24"]
        }
        shared = {
          name             = "snet-shared-services"
          address_prefixes = ["10.0.2.0/24"]
        }
        gateway = {
          name             = "GatewaySubnet"
          address_prefixes = ["10.0.254.0/24"]
        }
      }

      # Basic per-hub VPN configuration (overridden/populated via var.hub_vpn_configs)
      vpn = lookup(var.hub_vpn_configs, "primary", {
        enabled    = false
        name       = "vgw-${var.hub_vnet_name}"
        sku        = "VpnGw1"
        vpn_type   = "RouteBased"
        generation = "Generation2"
        enable_bgp = false
        sites      = {}
      })
    }
  }
}