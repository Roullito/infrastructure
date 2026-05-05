## Networking de emplois-cnav

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | >= 2.60.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.74.0 |
| <a name="provider_scaleway.tmp"></a> [scaleway.tmp](#provider\_scaleway.tmp) | 2.74.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_ipam_ip.kubernetes_public_gateway_private_network_ip](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/ipam_ip) | resource |
| [scaleway_ipam_ip.strongswan_public_gateway_private_network_ip](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/ipam_ip) | resource |
| [scaleway_lb.traefik_lb](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/lb) | resource |
| [scaleway_lb_ip.traefik_lb_ip](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/lb_ip) | resource |
| [scaleway_lb_private_network.traefik_lb_private_network](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/lb_private_network) | resource |
| [scaleway_vpc.vpc](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc) | resource |
| [scaleway_vpc_gateway_network.kubernetes_gateway_network](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_gateway_network) | resource |
| [scaleway_vpc_gateway_network.strongswan_gateway_network](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_gateway_network) | resource |
| [scaleway_vpc_private_network.kubernetes_private_network](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_private_network) | resource |
| [scaleway_vpc_private_network.strongswan_private_network](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_private_network) | resource |
| [scaleway_vpc_public_gateway.kubernetes_public_gateway](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_public_gateway) | resource |
| [scaleway_vpc_public_gateway.strongswan_public_gateway](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_public_gateway) | resource |
| [scaleway_vpc_public_gateway_ip.kubernetes_public_gateway_ip](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_public_gateway_ip) | resource |
| [scaleway_vpc_public_gateway_ip.strongswan_public_gateway_ip](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_public_gateway_ip) | resource |
| [scaleway_vpc_route.kubernetes_to_strongswan](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_route) | resource |
| [scaleway_vpc_route.strongswan_to_kubernetes](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_route) | resource |
| [scaleway_account_project.emplois_cnav](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_managed"></a> [managed](#input\_managed) | Indicates the resource is managed by Terraform | `string` | `"Managed by Terraform"` | no |
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
