variable "region" {
  description = "The region to deploy the GKE cluster in."
  type        = string
}

variable "common_config" {
  description = "Common configuration for all regions."
  type = object({
    environment = string # env: like staging or prod
    project_id  = string # the GCP project to deploy resources into

    # Which IP ranges are allowed to communicate with the control plane
    gke_master_authorized_ranges = map(string)

    # The nodepools to create for the GKE cluster
    gke_nodepools = map(object({
      node_machine_type = string
      min_node_count    = number
      max_node_count    = number
      node_labels       = optional(map(string))
    }))

    gke_workload_runner_sa_email  = string
    gke_default_max_pods_per_node = optional(number)

    # Whether to enable vertical pod autoscaling
    gke_vertical_pod_autoscaling = optional(bool)

    # Which GKE addons to enable
    gke_addons = optional(map(any))

    # Labels to add
    gke_labels = optional(map(any))

    # GKE private cluster config
    gke_private_cluster_config = object({
      enable_private_nodes    = bool
      enable_private_endpoint = bool
      master_global_access    = bool
    })
  })
}

variable "gke_cluster_network_name" {
  description = "The name of the VPC to deploy the networking infra inside of"
  type        = string
  default     = "gke-application-cluster-vpc"
}

variable "gke_node_locations" {
  description = "The zones to deploy the GKE nodes in. Generally 1 zone for staging and two zones for production"
  type        = list(string)
}

variable "gke_networking" {
  description = "The networking configuration for the GKE cluster."
  type = object({
    master_ipv4_cidr_block      = string # CIDR block for control plane nodes
    ip_cidr_range               = string # CIDR block for worker nodes
    pods_secondary_ip_range     = string # CIDR block for pods
    services_secondary_ip_range = string # CIDR block for services
  })
}
