output "gateway_id" {
  description = "The Resource ID of the VPN Gateway."
  value       = azurerm_virtual_network_gateway.vpn.id
}

output "gateway_name" {
  description = "The name of the VPN Gateway."
  value       = azurerm_virtual_network_gateway.vpn.name
}

output "public_ip_address" {
  description = "The public IP address assigned to the VPN Gateway."
  value       = azurerm_public_ip.vpn.ip_address
}

output "connection_ids" {
  description = "Map of Site-to-Site VPN connection IDs keyed by site name."
  value       = { for k, v in azurerm_virtual_network_gateway_connection.s2s : k => v.id }
}