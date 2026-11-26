environment      = "dev"
location         = "centralus"
enable_telemetry = true
hub_vnet_name    = "vnet-platform-connectivity-dev"

hub_vpn_configs = {
  primary = {
    enabled    = true
    name       = "vgw-hub-dev-001"
    sku        = "VpnGw1AZ"
    vpn_type   = "RouteBased"
    generation = "Generation1"
    enable_bgp = false
    sites      = []
  }
}