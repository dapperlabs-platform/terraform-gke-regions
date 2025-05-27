module "gke_vpc_nat_addresses_regions" {
  source     = "github.com/dapperlabs-platform/terraform-google-net-address?ref=v1.0.0"
  for_each   = local.region_configs
  project_id = var.common_config.project_id
  external_addresses = {
    for i in range(each.value.nat_ip_count) :
    "${each.key}-nat-${i + 1}" => each.key
  }
}

module "gke_vpc_regions" {
  source     = "github.com/dapperlabs-platform/terraform-google-net-vpc?ref=v1.1.0"
  project_id = var.common_config.project_id
  name       = var.gke_cluster_network_name

  # Create a subnet for each region
  subnets = flatten(
    [for region, value in local.region_configs :
      [for name, subnet in value.subnets : {
        ip_cidr_range = subnet.ip_cidr_range
        name          = name
        region        = region
        secondary_ip_range = {
          pods     = subnet.pods_secondary_ip_range
          services = subnet.services_secondary_ip_range
        }
      }]
  ])

  # We don't want new VPCs, just want to add subnets to the existing VPC
  vpc_create = false
}

module "cloud-nat" {
  for_each = local.region_configs

  source                  = "github.com/dapperlabs-platform/terraform-google-net-cloudnat?ref=v1.1.0"
  project_id              = var.common_config.project_id
  region                  = each.key
  name                    = "${each.key}-nat"
  router_network          = module.gke_vpc_regions.name
  config_min_ports_per_vm = 1024
  addresses               = [for k, value in module.gke_vpc_nat_addresses_regions[each.key].external_addresses : value.self_link]
}
