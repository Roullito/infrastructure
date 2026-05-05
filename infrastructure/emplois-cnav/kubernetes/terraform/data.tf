data "scaleway_account_project" "emplois_cnav" {
  name     = "emplois-cnav"
  provider = scaleway.tmp
}

data "scaleway_vpc_private_network" "kubernetes_private_network" {
  name = "emplois-cnav-kubernetes-private-network"
}

data "sops_file" "secrets" {
  source_file = "secrets.enc.yaml"
}
