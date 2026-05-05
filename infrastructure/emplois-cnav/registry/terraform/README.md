## Container registry spécifique à `emplois-cnav`

### Gestion des images

Les images Docker sont mises à disposition par le GIP MDS sur l'outil de partage d'InGroupe (cf. credentials dans notre vault).
Dossier : `GIP-MDS/Logiciels/Suite Jeton/Ubuntu - Images DOCKER/`

Ils ne disposent pas de registry, d'où la nécessiter de télécharger les images et les charger sur celui-ci.

#### Authentification sur le registry

Pré-requis : disposer d'une clé ayant accès au registry

```bash
docker login rg.fr-par.scw.cloud/emplois-cnav-registry -u nologin --password-stdin <<< "$SCW_SECRET_KEY"
```

#### Chargement local des images téléchargées

```bash
docker load < ~/Downloads/sj-GIPMDS-2022-sj-passerelle-interops-a-2026.01.21-0912/sj-GIPMDS-2022-sj-passerelle-interops-a-2026.01.21-0912.tar.gz
docker load < ~/Downloads/sj-GIPMDS-2022-sj-jetonv3-2026.01.21-0912/sj-GIPMDS-2022-sj-jetonv3-2026.01.21-0912.tar.gz
docker load < ~/Downloads/sj-GIPMDS-2022-sj-ihm-web-2026.01.21-0912/sj-GIPMDS-2022-sj-ihm-web-2026.01.21-0912.tar.gz
```

#### Retag + chargement des images sur ce registry

Les images portent toutes le même nom, c'est leur version qui permet de distinguer `jetonv3` d'`interops-a` et `ihm-web`.  
On privilégiera des images distinctes et au versionning plus simple (en préservant leur calendar versionning).

```bash
# Current version tag
docker tag sj:GIPMDS-2022-sj-jetonv3-2026.01.21-0912 rg.fr-par.scw.cloud/emplois-cnav-registry/sj-jetonv3:2026-01-21
docker push rg.fr-par.scw.cloud/emplois-cnav-registry/sj-jetonv3:2026-01-21
docker tag sj:GIPMDS-2022-sj-passerelle-interops-a-2026.01.21-0912 rg.fr-par.scw.cloud/emplois-cnav-registry/sj-interops-a:2026-01-21
docker push rg.fr-par.scw.cloud/emplois-cnav-registry/sj-interops-a:2026-01-21
docker tag sj:GIPMDS-2022-sj-ihm-web-2026.01.21-0912 rg.fr-par.scw.cloud/emplois-cnav-registry/sj-ihm-web:2026-01-21
docker push rg.fr-par.scw.cloud/emplois-cnav-registry/sj-ihm-web:2026-01-21

# Update latest tag
docker tag sj:GIPMDS-2022-sj-jetonv3-2026.01.21-0912 rg.fr-par.scw.cloud/emplois-cnav-registry/sj-jetonv3:latest
docker push rg.fr-par.scw.cloud/emplois-cnav-registry/sj-jetonv3:latest
docker tag sj:GIPMDS-2022-sj-passerelle-interops-a-2026.01.21-0912 rg.fr-par.scw.cloud/emplois-cnav-registry/sj-interops-a:latest
docker push rg.fr-par.scw.cloud/emplois-cnav-registry/sj-interops-a:latest
docker tag sj:GIPMDS-2022-sj-ihm-web-2026.01.21-0912 rg.fr-par.scw.cloud/emplois-cnav-registry/sj-ihm-web:latest
docker push rg.fr-par.scw.cloud/emplois-cnav-registry/sj-ihm-web:latest
```

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
| [scaleway_registry_namespace.emplois_cnav_registry](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/registry_namespace) | resource |
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
