# Rapport DevSecOps — Pipeline CI/CD sur TerraGoat

> TYC 2025/2026 — Master Infra — DevSecOps
> Auteur : Ryan
> Dépôt : https://github.com/Zireor/terragoat-devsecops

---

## 1. Objectif

Mettre en place une chaîne **CI/CD** permettant d'**analyser**, **sécuriser** et
**déployer automatiquement** une infrastructure Cloud décrite en Infrastructure as Code
(Terraform), à partir du dépôt volontairement vulnérable **TerraGoat**.

Objectifs détaillés :
- Automatiser l'analyse de sécurité de l'IaC (scanners intégrés à la pipeline).
- Identifier les mauvaises configurations de sécurité.
- Corriger les vulnérabilités les plus critiques.
- Générer et conserver les rapports d'analyse (artefacts).
- Documenter les risques, corrections et bonnes pratiques.

---

## 2. Choix techniques

| Élément | Choix | Justification |
|---------|-------|---------------|
| CI/CD | **GitHub Actions** | Gratuit/illimité en dépôt public, TerraGoat déjà sur GitHub |
| Déploiement | **LocalStack** (AWS mocké) | Déploiement réel sans coût ni compte cloud |
| Version Terraform | **Modernisée** (≥ 0.12) | TerraGoat utilise une syntaxe récente ; la 0.12 stricte serait un retour en arrière |
| Scanners | **TFLint, Gitleaks, Checkov** | Couverture qualité + secrets + mauvaises configs |
| Documentation | **terraform-docs** | Génération auto de la doc de l'infra |

---

## 3. Architecture de la pipeline

| Stage | Outil | Rôle | Artefact produit |
|-------|-------|------|------------------|
| `lint` | TFLint | Qualité / modernité du code Terraform | rapport lint |
| `secrets` | Gitleaks | Détection de secrets en dur | rapport secrets |
| `security` | Checkov | Mauvaises configurations de sécurité | rapports SARIF / texte |
| `docs` | terraform-docs | Documentation auto de l'infrastructure | README généré |
| `deploy` | Terraform + LocalStack | Déploiement sur AWS mocké | logs de plan/apply |

> Déclencheurs (`triggers`) : `push` sur `main` et `pull_request` — afin de bloquer
> tout code non conforme **avant** la fusion (principe *shift-left security*).

---

## 4. Risques identifiés

| # | Risque | Criticité | Détecté par | Fichier(s) |
|---|--------|-----------|-------------|-----------|
| 1 | Clés AWS codées en dur | **Critique** | GitHub Push Protection + Gitleaks | `terraform/aws/ec2.tf`, `terraform/aws/providers.tf`, `terraform/aws/lambda.tf` |
| 2 | Syntaxe Terraform obsolète (0.11) | Moyenne | TFLint | `terraform/aws/consts.tf` |
| 3 | Versions de providers non contraintes | Faible | TFLint | `terraform/*/provider.tf` |
| 4 | Variables non typées | Faible | TFLint | `terraform/*/variables.tf` |

### Résultats Checkov (analyse des mauvaises configurations)

Le scan Checkov a produit **115 contrôles réussis / 213 échoués** (Terraform), plus
2 échecs Dockerfile et 1 secret (Lambda). Les échecs les plus **critiques** retenus
pour correction :

| # | Mauvaise configuration | Criticité | Check Checkov | Fichier |
|---|------------------------|-----------|---------------|---------|
| 5 | Secret AWS en dur dans la Lambda | **Critique** | CKV_SECRET_2 / CKV_AWS_45 | `lambda.tf` |
| 6 | RDS exposée publiquement | **Critique** | CKV_AWS_17 | `db-app.tf` |
| 7 | RDS / EBS / S3 non chiffrés au repos | **Élevée** | CKV_AWS_16 / 3 / 145 | `db-app.tf`, `ec2.tf`, `s3.tf` |
| 8 | Security Group SSH+HTTP ouverts au monde (`0.0.0.0/0`) | **Critique** | CKV_AWS_24 / 260 | `ec2.tf` |
| 9 | Buckets S3 sans Public Access Block | **Élevée** | CKV2_AWS_6 | `s3.tf`, `ec2.tf` |
| 10 | Politiques IAM `*:*` (sur-privilège) | **Élevée** | CKV_AWS_355 / 290 | `iam.tf`, `db-app.tf` |
| 11 | Subnets attribuant une IP publique par défaut | Moyenne | CKV_AWS_130 | `ec2.tf` |
| 12 | KMS sans rotation de clé | Moyenne | CKV_AWS_7 | `kms.tf` |
| 13 | ECR : tags mutables, pas de scan, pas de chiffrement | Moyenne | CKV_AWS_51 / 163 / 136 | `ecr.tf` |
| 14 | RDS sans sauvegarde (`backup_retention_period = 0`) | Moyenne | CKV_AWS_133 | `db-app.tf` |

> Le grand nombre d'échecs restants (logging, multi-AZ, deletion protection, audit,
> backtracking Aurora…) est **attendu** sur TerraGoat (cf. §9) ; la correction se
> concentre sur les risques exploitables à fort impact (exposition réseau, secrets,
> chiffrement, sur-privilèges).

---

## 5. Corrections apportées

| # | Problème | Avant | Après |
|---|----------|-------|-------|
| 1 | Syntaxe `type` obsolète (Terraform 0.11) | `type = "string"` | `type = string` |
| 2 | Interpolations dépréciées (8 fichiers) | `"${var.ami}"` | `var.ami` |
| 3 | Index déprécié | `.certificate_authority.0.data` | `.certificate_authority[0].data` |
| 4 | Provider AWS avec clés en dur (inutilisé) | bloc `plain_text_access_keys_provider` | **supprimé** |
| 5 | Variables non typées (`consts.tf`) | `variable "region" {}` | `type = string` ajouté |
| 6 | Versions de providers non contraintes | aucune | bloc `required_providers` (`aws ~> 5.0`) + `required_version >= 1.7` |
| 7 | Anti-pattern `null_resource` + `provisioner local-exec` | `null_resource "push_image"` (build/push Docker) | **supprimé** |
| 8 | Clés AWS dans le `user_data` EC2 | `export AWS_ACCESS_KEY_ID=...` | retirées + commentaire « utiliser un rôle IAM » |
| 9 | Secrets présents dans l'historique git (5 occurrences) | clés AWS + mots de passe DB dans d'anciens commits | **historique réécrit** (`git filter-repo`) → `no leaks found` |
| 10 | Secret AWS en dur dans la Lambda | bloc `environment { access_key/secret_key }` | **supprimé** (la Lambda utilise son rôle IAM) ; runtime obsolète `nodejs12.x` → `nodejs18.x` |
| 11 | RDS exposée et non sécurisée | `publicly_accessible = true`, `storage_encrypted = false`, `backup_retention_period = 0` | `false` / `true` / `7` |
| 12 | Security Group ouvert au monde | ingress `0.0.0.0/0` ports 22 & 80 | restreint au CIDR du VPC + `description` ajoutée ; egress limité à 443 |
| 13 | Volume EBS non chiffré | `#encrypted = false` (commenté) | `encrypted = true` |
| 14 | Subnets avec IP publique auto | `map_public_ip_on_launch = true` | `false` (×2) |
| 15 | Buckets S3 non chiffrés / publics | aucun chiffrement, pas de Public Access Block | SSE-KMS + `aws_s3_bucket_public_access_block` sur les 6 buckets (`data`, `financials`, `operations`, `data_science`, `logs`, `flowbucket`) + versioning |
| 16 | Politiques IAM `*:*` | `Action: ["s3:*","ec2:*",...]`, `Resource: "*"` | actions **lecture seule** scopées + `Condition` région + ARN de bucket ciblé (`iam.tf`, `db-app.tf`) |
| 17 | KMS sans rotation | (rotation absente) | `enable_key_rotation = true` |
| 18 | ECR non durci | `image_tag_mutability = "MUTABLE"`, pas de scan ni chiffrement | `IMMUTABLE` + `scan_on_push = true` + `encryption_configuration` KMS |

Détail correction #1 : 4 occurrences corrigées dans `terraform/aws/consts.tf`
(variables `ami`, `dbname`, `password`, `neptune-dbname`). Résultat : suppression des
**4 erreurs fatales** TFLint (`Invalid quoted type constraints`) qui empêchaient
l'analyse du module AWS.

Détail corrections #2 et #3 : appliquées **automatiquement** via `tflint --fix`
(exécuté en conteneur Docker, sans installation), sur tout le module `terraform/aws/`.
Le diff a été **revu manuellement** avant commit (bonne pratique : ne jamais committer
un auto-fix sans le relire).

Détail correction #4 : le bloc provider contenant les clés AWS codées en dur était
signalé par TFLint comme *declared but not used* et a été retiré de
`terraform/aws/providers.tf`.

**Détail corrections #8 et #9 — éradication des secrets (stage `secrets` / Gitleaks) :**

1. **Détection** : le job Gitleaks (scan de tout l'historique, `fetch-depth: 0`) a
   identifié **5 secrets** : les clés AWS du `user_data` de `ec2.tf` et 3 mots de passe
   de base de données dans des fichiers Azure d'anciens commits.
2. **Correction du code actuel** : les clés AWS ont été retirées du `user_data` de
   `terraform/aws/ec2.tf` (bonne pratique : utiliser un **rôle IAM / instance profile**
   plutôt que des identifiants statiques).
3. **Constat clé** : retirer un secret du code **ne suffit pas** — il reste dans
   l'historique git (« un secret commité une fois est compromis »).
4. **Remédiation complète de l'historique** : réécriture de l'historique avec
   **`git filter-repo`** :
   - `--replace-text` pour remplacer les valeurs des secrets par des placeholders dans
     **tous les commits** ;
   - `--path terraform/azure --invert-paths` pour purger les fichiers Azure (déjà hors
     périmètre) qui contenaient les mots de passe.
   - Suivi d'un **force-push** de l'historique réécrit.
5. **Vérification** : nouveau scan Gitleaks → **`no leaks found`** (239 commits).

> Note : une sauvegarde du dépôt a été réalisée avant la réécriture (opération
> irréversible). En contexte d'entreprise, cette réécriture s'accompagnerait de la
> **révocation** des secrets exposés auprès du fournisseur cloud.

**Impact mesuré (scan Checkov avant / après corrections, framework Terraform) :**

| | Contrôles réussis | Contrôles échoués |
|---|-------------------|-------------------|
| Avant | 115 | 213 |
| **Après** | **181** | **170** |

Soit **+66 contrôles conformes** et **-43 échecs**. Les **170 échecs résiduels**
correspondent à des durcissements de second rang non exploitables directement
(Multi-AZ, deletion protection, monitoring avancé, logging d'audit, clusters Aurora /
Neptune / Elasticsearch / EKS hors périmètre applicatif) et sont **assumés** sur un
dépôt volontairement vulnérable (cf. §9). Le job `secrets` (Gitleaks + Checkov secrets)
est quant à lui **totalement vert** (CKV_SECRET_2 corrigé).

**Principe directeur des corrections #10 à #18 — *secure by default* :**
chaque correction supprime une exposition concrète (réseau, donnée en clair,
sur-privilège) plutôt que de masquer l'alerte. On applique le **moindre privilège**
(IAM scopé en lecture seule + conditions), le **chiffrement au repos** systématique
(KMS), le **blocage de l'accès public** (defense in depth : Public Access Block en plus
des ACL privées) et la **réduction de la surface réseau** (SG restreint au VPC, plus
d'IP publique automatique).

---

## 6. Bonnes pratiques mises en œuvre

- **Pipeline et code dans un dépôt unique** : la CI/CD est versionnée avec l'IaC
  qu'elle teste (traçabilité, cohérence des commits).
- **Versions des actions GitHub épinglées** (`@v4`, ou hash de commit) → protection
  contre les attaques de **supply-chain**.
- **Jobs séparés** (lint / secrets / security / docs / deploy) → exécution parallèle,
  isolation des échecs, lisibilité.
- **Détection de secrets en amont** : la *Push Protection* GitHub a bloqué les clés AWS
  dès le push initial, avant même la pipeline (défense en profondeur).
- **Documentation rédigée au fil de l'eau** → traçabilité des décisions et des risques.
- **Documentation-as-code** : la doc de l'infra (`TERRAFORM.md`) est **régénérée
  automatiquement** par la pipeline (terraform-docs) à chaque push → elle reste toujours
  synchrone avec le code, contrairement à une doc maintenue à la main.
- **Correction de la cause plutôt que masquage** : l'erreur TFLint de syntaxe obsolète
  a été corrigée (modernisation), et non simplement ignorée.
- **Politique de *gating* différenciée** : la pipeline échoue sur les **erreurs
  bloquantes** mais tolère les **avertissements de style**
  (`tflint --minimum-failure-severity=error`). On évite les faux blocages tout en
  conservant la visibilité des warnings dans les logs.
- **Scan de secrets sur tout l'historique** (`fetch-depth: 0`) → un secret supprimé du
  code actuel mais présent dans d'anciens commits reste détecté.
- **Remédiation profonde des secrets** : au-delà du retrait dans le code, réécriture de
  l'historique (`git filter-repo`) pour éradiquer les secrets de tous les commits —
  illustre le principe « un secret commité une fois est compromis ».
- **Secrets masqués dans les logs CI** (`gitleaks --redact`) → on ne réaffiche jamais un
  secret en clair dans la sortie de la pipeline.
- **Contraintes de versions** (`required_version`, `required_providers`) → infra
  reproductible et maîtrise de la chaîne d'approvisionnement des providers.
- **Suppression des anti-patterns** : retrait du `null_resource` + `provisioner
  local-exec` (build/push Docker), déconseillés par HashiCorp (« last resort »).
  Terraform décrit de l'**état déclaratif**, pas des scripts impératifs.
- **Outils exécutés en conteneur** (`docker run ghcr.io/.../tflint`) → pas
  d'installation locale, environnement reproductible.
- **Gating fiable avec `set -o pipefail`** : un piège a été identifié — une commande
  `outil | tee rapport.txt` renvoie par défaut le code de sortie de `tee` (0), masquant
  l'échec de l'outil. Concrètement, le job Gitleaks passait **au vert alors que
  5 secrets étaient détectés** (faux négatif de gating). Corrigé avec `set -o pipefail`
  pour que le pipe propage le vrai code d'erreur. Leçon : **ne jamais se fier à un
  statut vert sans vérifier la sortie réelle de l'outil.**

---

## 7. Rapports d'analyse générés

Les rapports sont produits **automatiquement** par la pipeline et conservés en tant
qu'**artefacts** GitHub Actions (téléchargeables depuis l'onglet *Actions* → run → section
*Artifacts*).

| Rapport | Outil | Format |
|---------|-------|--------|
| Lint Terraform | TFLint | texte / compact |
| Secrets | Gitleaks | JSON / SARIF |
| Mauvaises configurations | Checkov | CLI / SARIF |
| Documentation infra (`TERRAFORM.md` : providers / inputs / outputs) | terraform-docs | Markdown |

_(Liens vers les runs et artefacts à ajouter une fois la pipeline complète.)_

---

## 8. Périmètre du projet

Le projet est volontairement **recentré sur le module AWS** (`terraform/aws/`) :
- c'est le cloud effectivement **déployé** (sur LocalStack, qui émule AWS) ;
- les modules `azure/`, `gcp/`, `oracle/`, `alicloud/` ont été **retirés** du dépôt pour
  garder une chaîne CI/CD cohérente et lisible (un seul cloud analysé et déployé) ;
- le dossier `gitlabci/` (configuration GitLab) a été supprimé car le projet utilise
  **GitHub Actions**.

Le module AWS contient à lui seul de nombreuses mauvaises configurations (S3 publics,
RDS non chiffrés, Security Groups ouverts, secrets…), suffisantes pour démontrer la
chaîne de détection et de correction.

---

## 9. Note sur le dépôt

TerraGoat (`bridgecrewio/terragoat`) est un dépôt **volontairement vulnérable** conçu
pour l'entraînement. Le grand nombre de vulnérabilités détectées est donc **attendu** :
l'objectif du projet n'est pas d'atteindre zéro vulnérabilité, mais de **mettre en place
la chaîne de détection automatisée** et de **corriger les vulnérabilités les plus
critiques** en documentant la démarche.
