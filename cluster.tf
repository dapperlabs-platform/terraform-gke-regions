module "gke_application_cluster_regions" {
  source = "github.com/dapperlabs-platform/terraform-google-gke-cluster?ref=v0.10.3"

  project_id                   = var.common_config.project_id
  name                         = "${var.region}-application"
  release_channel              = var.common_config.environment == "production" ? "STABLE" : "REGULAR"
  location                     = var.region
  network                      = module.gke_vpc_regions.self_link
  subnetwork                   = module.gke_vpc_regions.subnet_self_links["${var.region}/gke-${var.region}"]
  secondary_range_pods         = "pods"
  secondary_range_services     = "services"
  default_max_pods_per_node    = var.common_config.gke_default_max_pods_per_node
  authenticator_security_group = "gke-security-groups@dapperlabs.com"


  addons                   = try(var.common_config.gke_addons, {})
  node_locations           = var.gke_node_locations
  master_authorized_ranges = var.common_config.gke_master_authorized_ranges
  private_cluster_config   = merge(var.common_config.gke_private_cluster_config, { master_ipv4_cidr_block = var.gke_networking.master_ipv4_cidr_block })
  labels                   = try(var.common_config.gke_labels, {})
  vertical_pod_autoscaling = try(var.common_config.gke_vertical_pod_autoscaling, false)
  secondary_region         = true
  namespace_protection     = false
}

module "gke_application_cluster_nodepools_regions" {
  for_each                    = var.common_config.gke_nodepools
  source                      = "github.com/dapperlabs-platform/terraform-google-gke-nodepool?ref=v0.9.3"
  project_id                  = var.common_config.project_id
  cluster_name                = module.gke_application_cluster_regions.name
  location                    = module.gke_application_cluster_regions.location
  name                        = "${var.region}-${each.key}"
  node_image_type             = "cos_containerd"
  node_machine_type           = each.value.node_machine_type
  node_service_account        = var.common_config.gke_workload_runner_sa_email
  node_service_account_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  autoscaling_config = {
    min_node_count = each.value.min_node_count
    max_node_count = each.value.max_node_count
  }

  node_labels = try(each.value.node_labels, {})

  node_tags = [
    module.gke_application_cluster_regions.name
  ]
}
