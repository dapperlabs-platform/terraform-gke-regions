output "cluster_endpoint" {
  value = module.gke_application_cluster_regions.endpoint
}

output "cluster_ca_certificate" {
  value = module.gke_application_cluster_regions.ca_certificate
}
