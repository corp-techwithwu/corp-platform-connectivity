###############################################################################
# Locals - Connectivity Hub
###############################################################################

locals {
  # Location and naming
  location    = var.location
  rg_name     = var.resource_group_name != "" ? var.resource_group_name : "rg-connectivity-hub-${var.environment}"
  dns_rg_name = var.dns_resource_group_name != "" ? var.dns_resource_group_name : "rg-connectivity-dns-${lower(var.environment)}-${replace(lower(local.location), " ", "")}-001"

  # Centralized tagging
  common_tags = merge(
    {
      created_by  = "terraform"
      project     = "corp platform connectivity"
      owner       = "avm"
      environment = var.environment
      managed_by  = "terraform"
    },
    var.custom_tags
  )

  # Read and parse CSV configuration for spoke virtual networks
  spoke_vnets_csv = fileexists("${path.module}/config/spoke_vnets.csv") ? csvdecode(file("${path.module}/config/spoke_vnets.csv")) : []

  # Clean and filter spoke entries:
  # Excludes header comments (#), empty lines, and example placeholder rows
  spoke_peers = {
    for row in local.spoke_vnets_csv :
    trimspace(row.spoke_name) => {
      spoke_name                   = trimspace(row.spoke_name)
      remote_virtual_network_id    = trimspace(row.remote_virtual_network_id)
      hub_vnet_key                 = try(trimspace(lookup(row, "hub_vnet_key", "")), "")
      allow_forwarded_traffic      = try(tobool(row.allow_forwarded_traffic), true)
      allow_gateway_transit        = try(tobool(row.allow_gateway_transit), false)
      use_remote_gateways          = try(tobool(row.use_remote_gateways), false)
      allow_virtual_network_access = try(tobool(row.allow_virtual_network_access), true)
    }
    if trimspace(lookup(row, "remote_virtual_network_id", "")) != ""
    && !startswith(trimspace(lookup(row, "spoke_name", "")), "#")
    && !can(regex("(?i)example|placeholder|<.*>", lookup(row, "remote_virtual_network_id", "")))
  }

  private_dns_zones = toset([
    # App Service / Web App
    "privatelink.azurewebsites.net",

    # Key Vault
    "privatelink.vaultcore.azure.net",

    # Storage (keep only the sub-resources you use, e.g., blob, file, dfs, queue, table)
    "privatelink.blob.core.windows.net",
    "privatelink.file.core.windows.net",

    # Database (specify the database engines you use, e.g., PostgreSQL, MySQL, SQL)
    "privatelink.postgres.database.azure.com",
    "privatelink.mysql.database.azure.com",
    "privatelink.database.windows.net",

    # AKS (private cluster API server zones usually include the region, e.g., privatelink.eastus.azmk8s.io)
    # "privatelink.<region>.azmk8s.io",

    # ACI (Azure Container Instances typically use privatelink.<region>.azurecontainer.io)
    # "privatelink.<region>.azurecontainer.io",

    # VM / virtual machine related services (VMs typically use auto-registration or custom DNS;
    # for Backup, Recovery Services, Bastion, Disk Access, etc., add the exact zone names)
  ])
}