## Infrastructure Kube spécifique à `emplois-cnav`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | >= 2.60.0 |
| <a name="requirement_sops"></a> [sops](#requirement\_sops) | >= 1.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.74.0 |
| <a name="provider_scaleway.tmp"></a> [scaleway.tmp](#provider\_scaleway.tmp) | 2.74.0 |
| <a name="provider_sops"></a> [sops](#provider\_sops) | 1.4.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_k8s_acl.cluster_acl](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/k8s_acl) | resource |
| [scaleway_k8s_cluster.cluster](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/k8s_cluster) | resource |
| [scaleway_k8s_pool.cluster_pool](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/k8s_pool) | resource |
| [scaleway_account_project.emplois_cnav](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |
| [scaleway_vpc_private_network.kubernetes_private_network](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/vpc_private_network) | data source |
| [sops_file.secrets](https://registry.terraform.io/providers/carlpett/sops/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_managed"></a> [managed](#input\_managed) | Indicates the resource is managed by Terraform | `string` | `"Managed by Terraform"` | no |
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
