terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.60.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = ">= 1.4"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_k8s_cluster" "cluster" {
  name                        = "emplois-cnav-cluster"
  description                 = var.managed
  version                     = "1.35"
  type                        = "kapsule"
  cni                         = "cilium_native"
  private_network_id          = data.scaleway_vpc_private_network.kubernetes_private_network.id
  delete_additional_resources = false

  auto_upgrade {
    enable                        = true
    maintenance_window_day        = "monday"
    maintenance_window_start_hour = "04"
  }
}

resource "scaleway_k8s_pool" "cluster_pool" {
  cluster_id         = scaleway_k8s_cluster.cluster.id
  name               = "default"
  node_type          = "GP1-XS"
  size               = 1
  autohealing        = true
  autoscaling        = false
  public_ip_disabled = true
}

resource "scaleway_k8s_acl" "cluster_acl" {
  cluster_id = scaleway_k8s_cluster.cluster.id

  dynamic "acl_rules" {
    for_each = local.cluster_allowed_ips
    content {
      ip          = acl_rules.value.ip
      description = acl_rules.key
    }
  }

}
