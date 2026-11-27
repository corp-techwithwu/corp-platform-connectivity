variable "resource_group_name" {
  description = "Name of the resource group where the Private DNS Zones will be deployed."
  type        = string
}

variable "private_dns_zones" {
  description = "Set of Private DNS Zone names to create."
  type        = set(string)
}

variable "virtual_networks" {
  description = "Map of virtual networks to link to each Private DNS Zone, keyed by resolver identifier."
  type = map(object({
    name = string
    id   = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to Private DNS Zones and virtual network links."
  type        = map(string)
  default     = {}
}
