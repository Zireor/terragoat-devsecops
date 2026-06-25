# TerraGoat — Infrastructure AWS

Infrastructure AWS décrite en Terraform, durcie dans le cadre du projet DevSecOps
(analyse statique automatisée + correction des vulnérabilités critiques). Le module
décrit un socle complet : réseau (VPC, sous-réseaux, Security Groups), stockage (S3
chiffrés KMS), calcul (EC2, Lambda), identité (IAM) et chiffrement (KMS).

> ⚠️ Ce code dérive de **TerraGoat** (dépôt volontairement vulnérable de Bridgecrew).
> Les vulnérabilités critiques ont été corrigées (voir `RAPPORT.md`), mais il subsiste
> des durcissements de second rang : ne pas utiliser tel quel en production.

## Usage

```hcl
# Déploiement local sur LocalStack (AWS émulé, sans coût)
terraform init
terraform plan
terraform apply -auto-approve \
  -target=aws_s3_bucket_public_access_block.data \
  -target=aws_security_group.web-node \
  -target=aws_iam_user_policy.userpolicy
```

Toutes les variables possèdent une valeur par défaut (voir tableau ci-dessous) :
aucun `-var` n'est requis pour un déploiement de démonstration.

<!-- BEGIN_TF_DOCS -->
<!-- Cette section est générée automatiquement par terraform-docs via la pipeline CI/CD.
     Ne pas éditer à la main : tout changement sera écrasé au prochain push. -->
<!-- END_TF_DOCS -->

## Bonnes pratiques de sécurité appliquées

- **Chiffrement au repos systématique** : buckets S3 et volumes EBS chiffrés via KMS
  (clé avec rotation activée).
- **Aucun accès public** : `aws_s3_bucket_public_access_block` sur tous les buckets,
  Security Groups restreints au CIDR du VPC (plus d'ouverture `0.0.0.0/0`).
- **Moindre privilège IAM** : politiques scopées en lecture seule, conditionnées par
  région, sans wildcard `*:*`.
- **Aucun secret en dur** : credentials retirés du code (rôles IAM), historique git
  purgé, détection continue par Gitleaks dans la pipeline.

## Documentation de l'infrastructure

Les tableaux **Requirements / Providers / Inputs / Outputs** ci-dessus sont
**générés et committés automatiquement** par le stage `docs` de la pipeline CI/CD
(terraform-docs), à chaque push. Ils restent donc toujours synchrones avec le code.
