###############################################################################
# Outputs - Connectivity Hub
###############################################################################

output "resource_group_id" {
  description = "The Resource ID of the Connectivity Hub resource group."
  value       = module.resource_group.resource_id
}

output "resource_group_name" {
  description = "The name of the Connectivity Hub resource group."
  value       = local.rg_name
}

output "dns_resource_group_id" {
  description = "The Resource ID of the DNS resource group."
  value       = module.dns_resource_group.resource_id
}

output "dns_resource_group_name" {
  description = "The name of the DNS resource group."
  value       = module.dns_resource_group.name
}

output "hub_vnets" {
  description = "Map of all provisioned Hub Virtual Networks with IDs and details."
  value = {
    for k, v in module.hub_vnet : k => {
      id            = v.resource_id
      name          = local.hub_vnets[k].name
      location      = try(local.hub_vnets[k].location, local.location)
      address_space = local.hub_vnets[k].address_space
      subnets       = v.subnets
    }
  }
}

output "peered_spoke_vnets" {
  description = "List of spoke virtual network names currently configured for Hub-side peering."
  value       = module.spoke_peering.peered_spoke_names
}

output "dns_resolvers" {
  description = "Map of deployed Azure DNS Private Resolvers and their Inbound Endpoint IPs."
  value = {
    for k, v in module.dns_resolver : k => {
      id                  = v.id
      name                = v.name
      inbound_endpoint_id = v.inbound_endpoint_id
      inbound_endpoint_ip = v.inbound_endpoint_ip
    }
  }
}