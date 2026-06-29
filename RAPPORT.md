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
| `deploy` | tflocal + LocalStack | Déploiement réel sur AWS mocké (S3/IAM/KMS) | logs de plan/apply |
| `docs` | terraform-docs | Documentation auto de l'infrastructure | README généré (committé) |
| `report` | jq (agrégation SARIF) | Rapport de sécurité consolidé trié par criticité | `SECURITY-REPORT.md` (committé) |

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
- **Protection de la branche `main` (workflow par PR)** : `main` n'est jamais poussée
  en direct. Tout changement passe par une branche `develop` (ou de feature) puis une
  **pull request** vers `main`. La PR déclenche la pipeline (`pull_request` dans les
  triggers) : on **vérifie que tous les jobs passent au vert avant la fusion** (statuts
  requis), et non après coup sur `main`. C'est la mise en application concrète du
  **shift-left** : le code non conforme est bloqué *avant* d'entrer dans la branche de
  référence. (À durcir côté GitHub par une *branch protection rule* : interdiction du
  push direct, PR + checks obligatoires, revue requise.)
- **Détection de secrets en amont** : la *Push Protection* GitHub a bloqué les clés AWS
  dès le push initial, avant même la pipeline (défense en profondeur).
- **Documentation rédigée au fil de l'eau** → traçabilité des décisions et des risques.
- **Documentation-as-code** : la doc de l'infra est **régénérée puis committée
  automatiquement dans le dépôt** par la pipeline (terraform-docs) à chaque push → elle
  est versionnée, visible dans le repo et toujours synchrone avec le code (contrairement
  à un artefact, simple pièce jointe de run). Garde-fous anti-boucle : commit uniquement
  en cas de changement réel + `[skip ci]` dans le message.
- **Doc hybride auto + narrative** (mode `inject`) : terraform-docs insère ses tableaux
  (Requirements / Inputs / Outputs) **entre des marqueurs** dans un `README.md` rédigé à
  la main (Usage, bonnes pratiques sécurité) → on combine la génération automatique et la
  connaissance métier. Les variables ont été enrichies de `description` pour que la
  colonne correspondante de la doc soit pertinente.
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

## 7. Déploiement sur LocalStack

Après les étapes d'analyse, la pipeline **déploie réellement** l'infrastructure sur
**LocalStack** (émulateur AWS), afin de prouver que le code Terraform n'est pas seulement
*bien écrit* mais aussi *applicable* — ce qu'aucun scanner statique ne vérifie.

### 7.1 Architecture du stage `deploy`

- **LocalStack en *service container*** : le job démarre un conteneur
  `localstack/localstack:3` exposé sur `localhost:4566`, avec
  `SERVICES: s3,iam,kms,ec2,sts`.
- **`tflocal`** (paquet `terraform-local`) : surcouche de Terraform qui **injecte
  automatiquement** les *endpoints* LocalStack et des **credentials factices**. Avantage :
  le `providers.tf` reste **intact** (aucun bloc `provider` spécifique à LocalStack à
  maintenir, donc aucun risque d'embarquer une config de test en production).
- **`needs: [lint, secrets, security]`** : on ne déploie **que si** l'analyse de sécurité
  est passée (principe *shift-left* : pas de déploiement sur du code non vérifié).
- **Vérification post-déploiement** : `awslocal s3 ls`, `kms list-keys`,
  `iam list-users` confirment que les ressources existent réellement dans l'émulateur
  (les logs sont conservés en artefact `localstack-deploy-report`).

### 7.2 Périmètre déployé et choix d'un `apply` ciblé

Le déploiement utilise un **`apply -target`** restreint aux ressources **S3, IAM et KMS**
(**16 ressources** créées avec succès : 5 buckets + 5 *public access blocks* + 1 objet S3
+ 1 clé + 1 alias KMS + 1 utilisateur + 1 clé d'accès + 1 politique IAM). Ce choix est
**assumé** : LocalStack en édition **Community** (gratuite) ne supporte pas l'ensemble des
services AWS. Les ressources hors périmètre sont écartées en connaissance de cause :

| Service | Statut LocalStack Community | Décision |
|---------|----------------------------|----------|
| S3 / IAM / KMS | ✅ Supportés | **Déployés** |
| EC2 | ⚠️ Partiel (instance ne passe pas en `running`) | Tenté en **phase bornée** (voir 7.3) |
| ECR | ❌ Feature **Pro** (`CreateRepository` → HTTP 501) | Exclu |
| RDS / EKS / Neptune / ElasticSearch | ❌ Features **Pro** | Exclus |

> L'`apply` ciblé produit un avertissement *« Resource targeting is in effect »* : c'est
> **attendu** et non une erreur — Terraform signale simplement qu'on n'applique qu'un
> sous-ensemble de la configuration.

### 7.3 EC2 : un déploiement borné dans le temps

Sur LocalStack Community, l'instance EC2 ne transite jamais vers l'état `running` que le
provider AWS attend → Terraform **patiente indéfiniment**. La solution retenue **garde la
tentative de déploiement EC2** mais en **deux phases** :

1. **Phase 1** — S3/IAM/KMS : rapides et fiables, **bloquantes** (cœur de la démo).
2. **Phase 2** — EC2 : encapsulée dans `timeout 240` et suffixée de `|| echo …` → la
   création est tentée pendant **4 min maximum**, et si LocalStack bloque, le job **n'échoue
   pas** (message non bloquant). On obtient ainsi un déploiement **toujours vert** sans
   jamais subir d'attente infinie.

### 7.4 Compatibilité avec le provider AWS v5

TerraGoat ayant été écrit pour une version ancienne du provider, le déploiement avec
**AWS provider v5** a nécessité quelques corrections de schéma (sans rapport avec la
sécurité, donc sans impact sur l'exercice TerraGoat) :

| Problème (provider v5) | Fichier | Correction |
|------------------------|---------|------------|
| `aws_db_instance.name` supprimé | `db-app.tf` | → `db_name` (argument **et** référence dans le `user_data`) |
| `aws_rds_cluster.engine` désormais requis | `rds.tf` (×9) | ajout de `engine = "aurora-mysql"` |

### 7.5 Pièges rencontrés et résolus (journal de débogage)

Le déploiement a demandé un vrai travail d'investigation, riche d'enseignements :

| Symptôme | Cause racine | Résolution |
|----------|--------------|------------|
| Conteneur quitte au démarrage (`exit 55`, *License activation failed*) | Le tag `:latest` exige désormais un `LOCALSTACK_AUTH_TOKEN` (licence) | Épingler `localstack/localstack:3` (Community, sans token) |
| `apply` **figé** sans aucune sortie après l'init (~30 min) | Service **`sts` absent** de `SERVICES` → le provider boucle en *retry* sur `GetCallerIdentity` (erreurs `InternalFailure`) | Ajouter `sts` à `SERVICES` |
| Échec création ECR (HTTP 501) | ECR = feature **Pro** | Retirer ECR du périmètre |

> Méthode de diagnostic clé (réutilisable) : interroger `GET /_localstack/health` pour
> lister l'état réel des services, et tester chaque appel sensible avec `awslocal`
> (`awslocal sts get-caller-identity`) **avant** de lancer Terraform. Cela a permis
> d'isoler la cause du gel en **un seul run** au lieu de subir des attentes en aveugle.

---

## 8. Rapports d'analyse générés

Les rapports sont produits **automatiquement** par la pipeline et conservés en tant
qu'**artefacts** GitHub Actions (téléchargeables depuis l'onglet *Actions* → run → section
*Artifacts*).

| Rapport | Outil | Format |
|---------|-------|--------|
| Lint Terraform | TFLint | texte / compact |
| Secrets | Gitleaks | JSON / SARIF |
| Mauvaises configurations | Checkov | CLI / SARIF |
| Documentation infra (providers / inputs / outputs, injectée dans `README.md`) | terraform-docs | Markdown |
| Déploiement LocalStack (apply + vérification `awslocal`) | tflocal | texte |
| **Rapport de sécurité consolidé** (`SECURITY-REPORT.md`) | jq (agrégation SARIF) | Markdown |

### Exploitation des findings : deux niveaux

Au-delà des artefacts bruts, les résultats de sécurité sont rendus **réellement
exploitables** :

1. **Onglet *Security* de GitHub** (*Code scanning*) : les SARIF de Checkov et Gitleaks
   sont publiés via `github/codeql-action/upload-sarif`. Chaque *finding* apparaît avec sa
   **criticité**, son **fichier:ligne** cliquable, sa règle, la déduplication et
   l'historique — et des **annotations directes dans les pull requests**.
2. **Rapport consolidé `SECURITY-REPORT.md`** : le job `report` agrège **tous** les SARIF
   avec `jq` en **un seul tableau trié par criticité** (HIGH / MEDIUM / LOW), affiché dans
   le résumé du run (`$GITHUB_STEP_SUMMARY`) **et committé dans le dépôt** (fichier
   versionné, consultable directement sur GitHub). Mapping appliqué : niveau SARIF
   `error` → **HIGH**, `warning` → **MEDIUM**, `note` → **LOW**.

---

## 9. Périmètre du projet

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

## 10. Note sur le dépôt

TerraGoat (`bridgecrewio/terragoat`) est un dépôt **volontairement vulnérable** conçu
pour l'entraînement. Le grand nombre de vulnérabilités détectées est donc **attendu** :
l'objectif du projet n'est pas d'atteindre zéro vulnérabilité, mais de **mettre en place
la chaîne de détection automatisée** et de **corriger les vulnérabilités les plus
critiques** en documentant la démarche.
