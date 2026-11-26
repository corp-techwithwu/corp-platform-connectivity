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
    p2s = {
      enabled       = true
      address_space = ["172.16.201.0/24"]
      aad_tenant_id = "da528e4a-a122-4392-b5c8-370e74e0236d"
      protocols     = ["OpenVPN"]
    }
  }
}