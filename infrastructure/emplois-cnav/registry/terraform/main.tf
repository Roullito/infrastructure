terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.60.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_registry_namespace" "emplois_cnav_registry" {
  name        = "emplois-cnav-registry"
  description = var.managed
  is_public   = false
}
