resource "azurerm_private_dns_zone" "this" {
  for_each = var.private_dns_zones

  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

locals {
  zone_virtual_network_links = {
    for link in flatten([
      for zone_name in var.private_dns_zones : [
        for vnet_key, vnet in var.virtual_networks : {
          key       = "${vnet_key}/${zone_name}"
          zone_name = zone_name
          vnet_key  = vnet_key
          vnet_name = vnet.name
          vnet_id   = vnet.id
        }
      ]
    ]) : link.key => link
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = local.zone_virtual_network_links

  name                  = "link-${each.value.vnet_name}-${replace(each.value.zone_name, ".", "-")}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.value.zone_name].name
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}
