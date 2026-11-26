environment      = "prod"
location         = "centralus"
enable_telemetry = false
hub_vnet_name    = "vnet-platform-connectivity-prod"

hub_vpn_configs = {
  primary = {
    enabled    = true
    name       = "vgw-hub-prod-001"
    sku        = "VpnGw1AZ"
    vpn_type   = "RouteBased"
    generation = "Generation1"
    enable_bgp = false

    sites = []
  }
}