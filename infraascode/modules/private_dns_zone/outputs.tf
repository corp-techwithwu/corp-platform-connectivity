output "private_dns_zone_ids" {
  description = "Map of created Private DNS Zone names to their resource IDs."
  value       = { for name, zone in azurerm_private_dns_zone.this : name => zone.id }
}
