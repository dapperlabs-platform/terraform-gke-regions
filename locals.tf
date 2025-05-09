locals {
  region_configs = {
    "${var.region}" = {
      subnets = {
        "gke-${var.region}" = {
          ip_cidr_range               = var.gke_networking.ip_cidr_range
          pods_secondary_ip_range     = var.gke_networking.pods_secondary_ip_range
          services_secondary_ip_range = var.gke_networking.services_secondary_ip_range
        }
      }
      nat_ip_count = 3
    }
  }
}
