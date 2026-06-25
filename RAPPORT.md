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
| Scanners | **TFLint, Gitleaks, Checkov, tfsec** | Couverture qualité + secrets + mauvaises configs |
| Documentation | **terraform-docs** | Génération auto de la doc de l'infra |

---

## 3. Architecture de la pipeline

| Stage | Outil | Rôle | Artefact produit |
|-------|-------|------|------------------|
| `lint` | TFLint | Qualité / modernité du code Terraform | rapport lint |
| `secrets` | Gitleaks | Détection de secrets en dur | rapport secrets |
| `security` | Checkov (+ tfsec) | Mauvaises configurations de sécurité | rapports SARIF / JSON |
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

_(Cette section sera complétée avec les résultats Checkov : exposition réseau,
buckets publics, absence de chiffrement, etc.)_

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

_(Section complétée au fil des corrections : chiffrement S3, blocage de l'accès public,
restriction des Security Groups, etc. — à venir avec Checkov.)_

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
| Mauvaises configurations | Checkov | CLI / SARIF / JSON |
| Mauvaises configurations | tfsec | SARIF |
| Documentation infra | terraform-docs | Markdown |

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
