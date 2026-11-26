###############################################################################
# Centralized Connectivity Hub
# Manages Hub VNets (defined in locals-hubvnet.tf) and Spoke Peering connections
###############################################################################


###############################################################################
# Resource Group (AVM Resource Module)
###############################################################################
module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.5.0"

  name             = local.rg_name
  location         = local.location
  enable_telemetry = var.enable_telemetry
  tags             = local.common_tags
}

###############################################################################
# HUB – AVM Virtual Network Module (Extendable)
# Provisions all Hub Virtual Networks and custom subnets from locals-hubvnet.tf
###############################################################################
module "hub_vnet" {
  for_each = local.hub_vnets

  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.17"

  name          = each.value.name
  location      = try(each.value.location, local.location)
  address_space = each.value.address_space

  # Pass the RG resource ID
  parent_id = module.resource_group.resource_id

  subnets = each.value.subnets

  enable_telemetry = var.enable_telemetry
  tags             = local.common_tags
}

###############################################################################
# Spoke Virtual Network Peering Submodule
# Uses native azurerm_virtual_network_peering to establish Hub-side peering
# without requiring cross-subscription write permissions on spoke subscriptions
###############################################################################
module "spoke_peering" {
  source = "./modules/spoke_peering"

  hub_virtual_networks = {
    for k, v in local.hub_vnets : k => {
      name                = v.name
      resource_group_name = local.rg_name
      id                  = module.hub_vnet[k].resource_id
    }
  }

  spoke_peers = local.spoke_peers
}


###############################################################################
# VPN Gateway Submodule
###############################################################################
module "vpn" {
  count  = var.vpn.enabled ? 1 : 0
  source = "./modules/vpn"

  name                = var.vpn.name
  location            = local.location
  resource_group_name = module.resource_group.name
  gateway_subnet_id   = module.hub_vnet["primary"].subnets["GatewaySubnet"].resource_id

  sku        = var.vpn.sku
  vpn_type   = var.vpn.vpn_type
  generation = var.vpn.generation
  enable_bgp = var.vpn.enable_bgp

  local_network_gateways = var.vpn.sites

  tags = local.common_tags
}