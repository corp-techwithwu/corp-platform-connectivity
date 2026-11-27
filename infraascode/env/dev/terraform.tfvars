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
    p2s = {
      enabled       = true
      address_space = ["172.16.201.0/24"]
      aad_tenant_id = "da528e4a-a122-4392-b5c8-370e74e0236d"
      protocols     = ["OpenVPN"]
    }
  }
}

hub_dns_resolver_configs = {
  primary = {
    enabled = true
    # Optional: pin a static IP inside 10.0.3.0/28 (first usable host IP in Azure is .4)
    inbound_private_ip_allocation_method = "Static"
    inbound_private_ip_address           = "10.0.3.4"
  }
}