locals {
  cluster_allowed_ips = yamldecode(data.sops_file.secrets.raw)["cluster_allowed_ips"]
}
