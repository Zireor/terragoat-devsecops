
data "aws_caller_identity" "current" {}

variable "company_name" {
  type        = string
  description = "Nom de l'entreprise, utilisé comme préfixe de nommage des ressources."
  default     = "acme"
}

variable "environment" {
  type        = string
  description = "Environnement de déploiement (ex. dev, staging, prod)."
  default     = "dev"
}

locals {
  resource_prefix = {
    value = "${data.aws_caller_identity.current.account_id}-${var.company_name}-${var.environment}"
  }
}



variable "region" {
  type        = string
  description = "Région AWS cible pour le déploiement des ressources."
  default     = "us-west-2"
}

variable "ami" {
  type        = string
  description = "ID de l'AMI utilisée pour les instances EC2."
  default     = "ami-09a5b0b7edf08843d"
}

variable "dbname" {
  type        = string
  description = "Name of the Database"
  default     = "db1"
}

variable "password" {
  type        = string
  description = "Database password"
  default     = "Aa1234321Bb"
}

variable "neptune-dbname" {
  type        = string
  description = "Name of the Neptune graph database"
  default     = "neptunedb1"
}
