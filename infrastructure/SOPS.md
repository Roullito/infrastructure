# SOPS — Inputs Terraform sensibles chiffrés dans le repo

Ce document décrit comment et quand utiliser [SOPS](https://github.com/getsops/sops) avec des
clés [age](https://github.com/FiloSottile/age) pour chiffrer les inputs Terraform sensibles directement dans le repo,
et comment gérer le cycle de vie des clés.

## Doctrine : SOPS vs Secret Manager Scaleway

Les deux mécanismes coexistent dans ce repo. Le critère de choix est **qui consomme la valeur** :

### SOPS (chiffré dans le repo, lu par Terraform au plan/apply)

À utiliser pour les **inputs de `terraform apply`** :

- valeurs structurées (maps, listes labelisées) qu'on veut review/diff/blame en PR
- faible cadence de rotation
- exemples : allowlists d'IPs cluster, emails admins/owners, IDs de partenaires tiers,
  configs bootstrap qu'on ne veut pas en clair

### Secret Manager Scaleway (runtime)

À utiliser pour les **secrets consommés par les workloads** :

- credentials applicatifs (mots de passe DB, clés API appelées par l'app, JWT signing keys)
- rotation indépendante des déploiements Terraform
- secrets « haute sensibilité prod » qu'on ne souhaite pas avoir sur le repo, même chiffrés

### Règle empirique

> Si Terraform **consomme** la valeur pour provisionner → SOPS.
> Si Terraform **crée/référence** la valeur pour qu'un workload la lise → Secret Manager.

## Architecture des clés

- Une clé AGE **dédiée à la CI**, dont la partie privée est stockée dans le secret GitHub Actions `SOPS_AGE_KEY`
- Une clé AGE **par utilisateur humain** (restreint à qui peut apply).
  Chacun peut la stocker localement dans `~/.config/sops/age/keys.txt`
- Les clés publiques de tous les recipients sont listées dans `.sops.yaml` à la racine du repo

La clé existante `AGE_PRIVATE_KEY` reste **réservée au chiffrement des plans Terraform CI**
(cf. `.github/workflows/_terraform-module.yml`) : on ne souhaite pas réutiliser (pas la même besoin de rotation
ni la même exposition).

## Setup local pour un nouvel utilisateur

`~/.config/sops/age/keys.txt` peut contenir plusieurs paires de clés (SOPS les essaie en cascade au déchiffrement),
donc on **append**, jamais on écrase avec `age-keygen -o`.
Un commentaire d'en-tête permet de retrouver et retirer la clé plus tard.

### 1. Générer sa clé localement

```bash
mkdir -p ~/.config/sops/age
key="$(age-keygen)"
{
  printf '\n# GIP Inclusion - Infrastructure\n'
  printf '%s\n' "$key"
} >> ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# Récupérer la clé publique à committer dans .sops.yaml
printf '%s\n' "$key" | grep "public key:"
```

**⚠️ MacOS** : SOPS suit XDG, qui sur macOS pointe par défaut vers `~/Library/Application Support/sops/age/keys.txt`
(et non `~/.config/`). Pour garder un chemin uniforme entre OS, suivre XDG et exporter dans son shell rc :

```bash
export SOPS_AGE_KEY_FILE=$HOME/.config/sops/age/keys.txt
```

### 2. S'ajouter à `.sops.yaml` (PR)

Le nouvel utilisateur ouvre une PR ajoutant sa pubkey sous `keys:` (avec un alias)
et dans les `creation_rules` souhaitées.

### 3. Re-wrap des fichiers chiffrés (par un recipient existant)

`sops updatekeys` doit lire la data key actuelle pour la re-wrapper avec le nouveau set de recipients
(il faut donc être **déjà recipient** pour l'exécuter). Le nouvel utilisateur ne peut pas se bootstrapper seul.

N'importe quel autre utilisateur déjà listé dans `.sops.yaml` tire la branche de la PR, exécute `make sops-rotate-keys`,
push, et la PR peut être mergée.

Une fois la PR mergée, le nouvel utilisateur peut déchiffrer / éditer.

## Édition d'un fichier chiffré

```bash
# Édition in-place (ouvre $EDITOR sur le contenu déchiffré, re-chiffre à la sauvegarde)
make sops-edit SERVICE=infrastructure/emplois-cnav/kubernetes

# Visualisation seule
make sops-decrypt SERVICE=infrastructure/emplois-cnav/kubernetes
```

## Création d'un nouveau fichier chiffré dans un module

1. Créer `secrets.enc.yaml` dans le dossier `terraform/` du module avec le contenu en clair
2. `make sops-encrypt SERVICE=infrastructure/<chemin-module>` (chiffre in-place)
3. Côté Terraform : ajouter le provider `carlpett/sops` et un
   `data "sops_file" "secrets" { source_file = "secrets.enc.yaml" }`
4. Le pre-commit hook `ensure-sops-encrypted` empêchera le commit d'un `secrets.enc.yaml` non chiffré

## Restreindre un fichier à un sous-set d'utilisateurs autorisés

Ajouter une règle plus spécifique **avant** la règle catch-all dans `.sops.yaml` :

```yaml
creation_rules:
  # Règle restreinte (matchée en premier)
  - path_regex: infrastructure/<module-sensible>/terraform/secrets\.enc\.yaml$
    key_groups:
      - age:
          - *platform_lead
          - *ci

  # Règle par défaut (catch-all)
  - path_regex: (^|/)secrets\.enc\.yaml$
    key_groups:
      - age:
          - *leo
          - *alice
          - *ci
```

Attention l'ordre importe : le premier match l'emporte !

## Offboarding d'un utilisateur

```bash
# 1. Retirer la pubkey de l'opérateur de .sops.yaml (alias et toutes les creation_rules)

# 2. Re-wrap la data key sur tous les fichiers chiffrés
make sops-rotate-keys

# 3. Commit
git add .sops.yaml '**/secrets.enc.yaml'
git commit -m "chore(sops): remove <name> from recipients"
```

⚠️ **Important** : `sops updatekeys` empêche l'ex-opérateur de déchiffrer les **futures** versions,
mais s'il a clone le repo avant son départ, il a déjà vu toutes les versions précédentes.
Pour les valeurs encore actives et réellement sensibles, **rotater la valeur source** en plus :

- IPs personnelles dans une allowlist : déjà retirées naturellement
- Credentials d'un provider : régénérer côté provider et committer la nouvelle valeur
- Dans le doute, poser la question ou regénérer

## Rotation de la clé CI

```bash
# 1. Générer une nouvelle paire age
age-keygen

# 2. Mettre à jour le secret GitHub `SOPS_AGE_KEY` (partie privée)
# 3. Mettre à jour la pubkey dans .sops.yaml
# 4. make sops-rotate-keys + commit
```

## CI

Le workflow `_terraform-module.yml` :

- installe SOPS via la step « Install SOPS »
- propage le secret `SOPS_AGE_KEY` en variable d'environnement
- le provider `carlpett/sops` lit automatiquement `SOPS_AGE_KEY` au plan

Aucun déchiffrement explicite à faire dans les jobs : Terraform s'en charge via le provider.

## Limite : visibilité dans les logs CI

SOPS chiffre **at-rest dans le repo** (PR diffs, recherches, blame, history).
Mais une fois qu'une valeur traverse Terraform pour devenir un attribut de ressource, elle apparaît dans la sortie
de `terraform plan` (donc dans le job summary GitHub Actions et l'artefact de plan).

Pour les valeurs typiquement gérées par SOPS (allowlists d'IPs, emails, identifiants tiers) c'est inévitable :
la ressource les consomme telles quelles.

Pour les **vrais secrets** (mots de passe, clés API), les providers les marquent en général `sensitive`
et le plan affiche `(sensitive value)`.
Idéalement privilégier le Secret Manager, à défaut si on introduit un secret de ce type via SOPS, bien vérifier
que l'attribut cible du provider est bien marqué `sensitive`.

## Anti-leak

Un hook `ensure-sops-encrypted` (cf. `.pre-commit-config.yaml`) vérifie que chaque `secrets.enc.yaml` staged
contient bien le bloc de métadonnées `sops:` (donc qu'il est chiffré).
Couplé avec gitleaks (déjà en place), ça donne deux filets de sécurité.

`*.dec.yaml` est gitignoré pour éviter les déchiffrements accidentellement versionnés.
