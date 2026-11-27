output "id" {
  description = "The Resource ID of the Azure DNS Private Resolver."
  value       = azurerm_private_dns_resolver.this.id
}

output "name" {
  description = "The name of the Azure DNS Private Resolver."
  value       = azurerm_private_dns_resolver.this.name
}

output "inbound_endpoint_id" {
  description = "The Resource ID of the Inbound Endpoint."
  value       = azurerm_private_dns_resolver_inbound_endpoint.this.id
}

output "inbound_endpoint_ip" {
  description = "The private IP address assigned to the Inbound Endpoint (configure this as your VPN/on-prem DNS target)."
  value       = azurerm_private_dns_resolver_inbound_endpoint.this.ip_configurations[0].private_ip_address
}