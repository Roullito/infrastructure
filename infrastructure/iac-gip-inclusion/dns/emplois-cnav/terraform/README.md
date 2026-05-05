# DNS — Emplois-CNAV

Enregistrements DNS pour l'interconnexion Emplois et CNAV.

Domaines pour accès aux applicatifs du cluster + vérifications pour les certificats Certigna.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | >= 2.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.74.0 |
| <a name="provider_scaleway.tmp"></a> [scaleway.tmp](#provider\_scaleway.tmp) | 2.74.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns-emplois-cnav"></a> [dns-emplois-cnav](#module\_dns-emplois-cnav) | ../../../../_modules/dns/records/terraform | n/a |

## Resources

| Name | Type |
|------|------|
| [scaleway_account_project.iac_gip_inclusion](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |
| [scaleway_lb.traefik_lb](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/lb) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
