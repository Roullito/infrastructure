## Instance Strongswan de emplois-cnav

Permet d'assurer la liaison IPSec avec la CNAV.

### Architecture réseau et contraintes Scaleway

#### Contexte

Les pods Kubernetes doivent pouvoir joindre les serveurs CNAV via le tunnel VPN IPsec, avec des **IPs sources spécifiques** selon l'environnement :
- **Intégration** : IP source `local_ip_integration` → endpoint CNAV `remote_ip_integration`
- **Production** : IP source `local_ip_production` → endpoint CNAV `remote_ip_production`

#### Contrainte Scaleway Kapsule

La solution idéale serait d'utiliser **Cilium Egress Gateway**, qui permet de faire du SNAT sur des pods sélectionnés par label. Cependant, **Scaleway Kapsule n'expose pas cette fonctionnalité** :
- Les prérequis sont présents (`bpf.masquerade=true`, `kube-proxy-replacement=true`)
- Mais le CRD `CiliumEgressGatewayPolicy` n'est pas installé
- Et l'option `enable-ipv4-egress-gateway` n'est pas activée

Un demande au support à été faite auprès de Scaleway : https://console.scaleway.com/support/tickets/1560303

#### Solution de contournement

Strongswan fait office de **passerelle NAT** pour les pods K8s, avec des IPs dédiées par environnement.

**Flux réseau :**

```
Pods InterOPS (IP dans le CIDR Cilium)
    │
    │ Destination: local_ip_integration ou local_ip_production
    │ (toutes deux rattachées à l'instance strongswan)
    ▼
┌───────────────────────────────────────────────────────────────────┐
│ PREROUTING (DNAT)                                                 │
│ Redirige vers l'endpoint CNAV :                                   │
│   - local_ip_integration → remote_ip_integration                  │
│   - local_ip_production → remote_ip_production                    │
└───────────────────────────────────────────────────────────────────┘
    │
    │ Destination: remote_ip_integration ou remote_ip_production (CNAV)
    ▼
┌───────────────────────────────────────────────────────────────────┐
│ POSTROUTING (SNAT)                                                │
│ Change l'IP source pour qu'elle soit acceptée par le tunnel IPsec │
│ Source: IP pod → local_ip_integration ou local_ip_production      │
│ (utilise conntrack pour se souvenir de la destination originale)  │
└───────────────────────────────────────────────────────────────────┘
    │
    │ Source: local_ip_integration ou local_ip_production
    │ Destination: remote_ip_integration ou remote_ip_production
    ▼
┌───────────────────────────────────────────────────────────────────┐
│ Tunnel IPsec                                                      │
│ Le paquet matche les selectors : leftsubnet → rightsubnet         │
│ Il est encapsulé et envoyé à la CNAV                              │
└───────────────────────────────────────────────────────────────────┘
    │
    ▼
CNAV (voit source = local_ip_integration ou local_ip_production)
```

**Règles iptables configurées via cloud-init :**

1. **DNAT** (PREROUTING) : redirige le trafic destiné aux IPs strongswan vers les endpoints CNAV
2. **SNAT** (POSTROUTING) : change l'IP source des pods (CIDR Cilium) vers l'IP strongswan correspondante, en utilisant `conntrack --ctorigdst` pour matcher sur la destination originale

**Isolation des environnements :**

L'isolation entre intégration et production est garantie par des **NetworkPolicies Kubernetes** (Cilium) qui restreignent l'egress de chaque namespace vers l'IP strongswan correspondante uniquement.

### Ajout de la PSK

La PSK doit être définie manuellement dans l'instance (`/etc/ipsec.secrets`), faute de pouvoir le faire de manière sécurisée depuis Terraform / Scaleway.  
En effet, elle a beau être stockée dans le secret manager, elle se retouve exposée à un moment ou un autre en clair dans le cloud-init (en base64, mais donc également visible de tous dans la console SW).  
L'idéal aurait été de pouvoir monter le secret en tant qu'env var / fichier dans l'instance.

TODO à moyen terme :
- Tout rappatrier ce qui est relatif à la CNAV sur un projet dédié pour mieux circonscrire les permissions (`emplois-cnav`, actuellement tout est sur `default` vu qu'on avait réservé les IP sur ce projet)
    - Ça imposera un changement d'IP du public gateway (qui ne peut être partagé sur différents projets chez Scaleway)
- Trouver le moyen de limiter qui a accès à l'instance via SSH
    - Actuellement toutes les clés ssh semblent ajoutées aux `authorized_keys` du bastion (public gateway) et de l'instance
    - A priori possible via cloud-init, idéalement en se basant sur des ressource terraform SSH

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
| [scaleway_instance_private_nic.strongswan_instance_private_nic](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/instance_private_nic) | resource |
| [scaleway_instance_security_group.strongswan_security_group](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/instance_security_group) | resource |
| [scaleway_instance_server.strongswan_instance](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/instance_server) | resource |
| [scaleway_ipam_ip.interops_integration_ip](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/ipam_ip) | resource |
| [scaleway_ipam_ip.interops_production_ip](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/ipam_ip) | resource |
| [scaleway_ipam_ip.strongswan_instance_private_network_ip](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/ipam_ip) | resource |
| [scaleway_vpc_public_gateway_pat_rule.ipsec_ike](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_public_gateway_pat_rule) | resource |
| [scaleway_vpc_public_gateway_pat_rule.ipsec_nat_t](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_public_gateway_pat_rule) | resource |
| [scaleway_account_project.emplois_cnav](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |
| [scaleway_secret_version.cnav_vpn_config](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/secret_version) | data source |
| [scaleway_vpc_private_network.strongswan_private_network](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/vpc_private_network) | data source |
| [scaleway_vpc_public_gateway.strongswan_public_gateway](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/vpc_public_gateway) | data source |
| [scaleway_vpc_public_gateway_ip.strongswan_public_gateway_ip](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/vpc_public_gateway_ip) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_managed"></a> [managed](#input\_managed) | Indicates the resource is managed by Terraform | `string` | `"Managed by Terraform"` | no |
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
