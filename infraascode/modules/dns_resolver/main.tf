resource "azurerm_private_dns_resolver" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  virtual_network_id  = var.virtual_network_id
  tags                = var.tags
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "this" {
  name                    = var.inbound_endpoint_name
  private_dns_resolver_id = azurerm_private_dns_resolver.this.id
  location                = var.location
  tags                    = var.tags

  ip_configurations {
    private_ip_allocation_method = var.inbound_private_ip_allocation_method
    private_ip_address           = var.inbound_private_ip_allocation_method == "Static" ? var.inbound_private_ip_address : null
    subnet_id                    = var.inbound_subnet_id
  }
}
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = var.private_dns_zones

  name                  = "link-${var.name}-${replace(each.value, ".", "-")}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
  tags                  = var.tags
}