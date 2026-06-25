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
| 1 | Syntaxe `type` obsolète | `type = "string"` | `type = string` |

_(Section complétée au fil des corrections : suppression des secrets, chiffrement S3,
blocage de l'accès public, restriction des Security Groups, etc.)_

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

## 8. Note sur le dépôt

TerraGoat (`bridgecrewio/terragoat`) est un dépôt **volontairement vulnérable** conçu
pour l'entraînement. Le grand nombre de vulnérabilités détectées est donc **attendu** :
l'objectif du projet n'est pas d'atteindre zéro vulnérabilité, mais de **mettre en place
la chaîne de détection automatisée** et de **corriger les vulnérabilités les plus
critiques** en documentant la démarche.
