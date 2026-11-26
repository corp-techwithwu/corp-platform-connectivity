locals {
  local_network_gateway_names = nonsensitive([
    for site in var.local_network_gateways : site.name
  ])
  local_network_gateways_by_name = {
    for site in var.local_network_gateways : site.name => site
  }
}

resource "azurerm_public_ip" "vpn" {
  name                = "pip-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "vpn" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  type          = "Vpn"
  vpn_type      = var.vpn_type
  active_active = false
  enable_bgp    = var.enable_bgp
  sku           = var.sku
  generation    = var.generation

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  dynamic "vpn_client_configuration" {
    for_each = var.p2s != null && var.p2s.enabled ? [var.p2s] : []

    content {
      address_space        = vpn_client_configuration.value.address_space
      vpn_auth_types       = ["AAD"]
      vpn_client_protocols = vpn_client_configuration.value.protocols

      aad_tenant   = "https://login.microsoftonline.com/${vpn_client_configuration.value.aad_tenant_id}"
      aad_audience = vpn_client_configuration.value.aad_audience
      aad_issuer = coalesce(
        vpn_client_configuration.value.aad_issuer,
        "https://sts.windows.net/${vpn_client_configuration.value.aad_tenant_id}/"
      )
    }
  }

  tags = var.tags
}

resource "azurerm_local_network_gateway" "sites" {
  for_each = toset(local.local_network_gateway_names)

  name                = "lng-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  gateway_address     = local.local_network_gateways_by_name[each.key].gateway_address
  address_space       = local.local_network_gateways_by_name[each.key].address_space

  tags = var.tags
}

resource "azurerm_virtual_network_gateway_connection" "s2s" {
  for_each = toset(local.local_network_gateway_names)

  name                = "cn-${var.name}-to-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name

  type                       = local.local_network_gateways_by_name[each.key].connection_type
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.sites[each.key].id
  shared_key                 = local.local_network_gateways_by_name[each.key].shared_key
  routing_weight             = local.local_network_gateways_by_name[each.key].routing_weight

  tags = var.tags
}