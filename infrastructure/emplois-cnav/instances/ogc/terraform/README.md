## Instance Windows OGC de emplois-cnav

Permet d'utiliser l'outil de configuration des conventions InterOPS (applicatif Java qui ne tourne que sous Windows).

Cette instance n'a pas vocation à tourner en permanence, mais uniquement quelques heures le temps de d'éditer la convention technique InterOPS.

### Connexion à l'instance

La connexion se fait via un accès RDP, plusieurs applications sont disponibles.

- Lors du déploiement l'IP (dynamique) est exposée en output
- Récupérer le mot de passe RDP avec `scw instance server get-rdp-password <server-id>`. Cela produit quelque chose du genre :
    ```
    Username           Administrator
    Password           <password>
    SSHKeyID           <id-ssh-key>
    SSHKeyDescription  <description>
    ```

### Installation d'OGC

- Le logiciel est à récupérer sur le "Wimidoc" d'InGroupe (société faisant la TMA d'InterOPS pour le compte du GIP MDS) : https://wimidoc.ingroupe.com/#/@workspaces/w/gip-mds/documents/directory/88339014 (GIP-MDS/Logiciels/Outil de Génération des Conventions/)
- Et à installer sur le Windows


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
| [scaleway_block_snapshot.ogc_installed_snapshot](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/block_snapshot) | resource |
| [scaleway_instance_ip.ogc_ip](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/instance_ip) | resource |
| [scaleway_instance_server.ogc_instance](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/instance_server) | resource |
| [scaleway_account_project.emplois_cnav](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |
| [scaleway_iam_ssh_key.leo_rsa](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/iam_ssh_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_managed"></a> [managed](#input\_managed) | Indicates the resource is managed by Terraform | `string` | `"Managed by Terraform"` | no |
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ogc_public_ip"></a> [ogc\_public\_ip](#output\_ogc\_public\_ip) | Public IP address of the OGC instance |
<!-- END_TF_DOCS -->
