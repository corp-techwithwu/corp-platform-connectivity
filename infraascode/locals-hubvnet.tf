locals {
  hub_vnets = {
    "primary" = {
      name          = var.hub_vnet_name
      location      = local.location
      address_space = ["10.0.0.0/16"]

      subnets = {
        default = {
          name             = "snet-default"
          address_prefixes = ["10.0.1.0/24"]
        }
        shared = {
          name             = "snet-shared-services"
          address_prefixes = ["10.0.2.0/24"]
        }
        gateway = {
          name             = "GatewaySubnet"
          address_prefixes = ["10.0.254.0/24"]
        }
      }
    }
  }
}