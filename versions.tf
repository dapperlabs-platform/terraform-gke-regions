terraform {
  required_version = ">= 1.3.8"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.0"
    }
    kubernetes = {
      source                = "hashicorp/kubernetes"
      version               = ">= 2.20"
      configuration_aliases = [kubernetes.regions]
    }
  }
}

data "google_client_config" "provider" {}

provider "kubernetes" {
  alias = "regions"
  host  = "https://${module.gke_application_cluster_regions.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    module.gke_application_cluster_regions.ca_certificate,
  )
}
