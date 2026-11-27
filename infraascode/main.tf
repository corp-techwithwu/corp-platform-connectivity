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
# DNS Resource Group (AVM Resource Module)
###############################################################################
module "dns_resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.5.0"

  name             = local.dns_rg_name
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
  dns_servers = var.hub_dns_resolver_configs[each.key].inbound_private_ip_address != null ? {
    dns_servers = [var.hub_dns_resolver_configs[each.key].inbound_private_ip_address]
  } : null

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
  for_each = toset(nonsensitive([
    for key, config in var.hub_vpn_configs : key
    if config.enabled
  ]))
  source = "./modules/vpn"

  name                = coalesce(var.hub_vpn_configs[each.key].name, "vgw-${local.hub_vnets[each.key].name}")
  location            = local.location
  resource_group_name = module.resource_group.name
  gateway_subnet_id   = module.hub_vnet[each.key].subnets["gateway"].resource_id

  sku        = var.hub_vpn_configs[each.key].sku
  vpn_type   = var.hub_vpn_configs[each.key].vpn_type
  generation = var.hub_vpn_configs[each.key].generation
  enable_bgp = var.hub_vpn_configs[each.key].enable_bgp

  local_network_gateways = var.hub_vpn_configs[each.key].sites
  p2s                    = var.hub_vpn_configs[each.key].p2s

  tags = local.common_tags
}

###############################################################################
# DNS Private Resolver Submodule
###############################################################################
module "dns_resolver" {
  for_each = toset([
    for key, config in var.hub_dns_resolver_configs : key
    if config.enabled
  ])
  source = "./modules/dns_resolver"

  name                = coalesce(var.hub_dns_resolver_configs[each.key].name, "dnspr-${local.hub_vnets[each.key].name}")
  location            = local.location
  resource_group_name = module.dns_resource_group.name
  virtual_network_id  = module.hub_vnet[each.key].resource_id

  inbound_endpoint_name                = var.hub_dns_resolver_configs[each.key].inbound_endpoint_name
  inbound_subnet_id                    = module.hub_vnet[each.key].subnets["dns_inbound"].resource_id
  inbound_private_ip_allocation_method = var.hub_dns_resolver_configs[each.key].inbound_private_ip_allocation_method
  inbound_private_ip_address           = var.hub_dns_resolver_configs[each.key].inbound_private_ip_address

  tags = local.common_tags
}

###############################################################################
# Private DNS Zone Submodule
###############################################################################
module "private_dns_zone" {
  source = "./modules/private_dns_zone"

  resource_group_name = module.dns_resource_group.name
  private_dns_zones   = local.private_dns_zones
  virtual_networks = {
    for key, resolver in module.dns_resolver : key => {
      name = resolver.name
      id   = module.hub_vnet[key].resource_id
    }
  }

  tags = local.common_tags
}