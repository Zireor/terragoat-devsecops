# Rapport de sécurité consolidé

_Généré le Fri Jun 26 13:24:00 UTC 2026 — agrégation Checkov + Gitleaks (SARIF)._

**Total de findings : 172**

| Criticité | Outil | Règle | Fichier | Ligne | Détail |
|-----------|-------|-------|---------|:-----:|--------|
| HIGH | Checkov | `CKV2_AWS_11` | `terraform/aws/eks.tf` | 44 | Ensure VPC flow logging is enabled in all VPCs |
| HIGH | Checkov | `CKV2_AWS_12` | `terraform/aws/ec2.tf` | 114 | Ensure the default security group of every VPC restricts all traffic |
| HIGH | Checkov | `CKV2_AWS_12` | `terraform/aws/eks.tf` | 44 | Ensure the default security group of every VPC restricts all traffic |
| HIGH | Checkov | `CKV2_AWS_41` | `terraform/aws/ec2.tf` | 1 | Ensure an IAM role is attached to EC2 instance |
| HIGH | Checkov | `CKV2_AWS_52` | `terraform/aws/es.tf` | 1 | Ensure AWS ElasticSearch/OpenSearch Fine-grained access control is enabled |
| HIGH | Checkov | `CKV2_AWS_58` | `terraform/aws/neptune.tf` | 1 | Ensure AWS Neptune cluster deletion protection is enabled |
| HIGH | Checkov | `CKV2_AWS_59` | `terraform/aws/es.tf` | 1 | Ensure ElasticSearch/OpenSearch has dedicated master node enabled |
| HIGH | Checkov | `CKV2_AWS_60` | `terraform/aws/db-app.tf` | 1 | Ensure RDS instance with copy tags to snapshots is enabled |
| HIGH | Checkov | `CKV2_AWS_61` | `terraform/aws/ec2.tf` | 268 | Ensure that an S3 bucket has a lifecycle configuration |
| HIGH | Checkov | `CKV2_AWS_61` | `terraform/aws/s3.tf` | 1 | Ensure that an S3 bucket has a lifecycle configuration |
| HIGH | Checkov | `CKV2_AWS_61` | `terraform/aws/s3.tf` | 110 | Ensure that an S3 bucket has a lifecycle configuration |
| HIGH | Checkov | `CKV2_AWS_61` | `terraform/aws/s3.tf` | 141 | Ensure that an S3 bucket has a lifecycle configuration |
| HIGH | Checkov | `CKV2_AWS_61` | `terraform/aws/s3.tf` | 49 | Ensure that an S3 bucket has a lifecycle configuration |
| HIGH | Checkov | `CKV2_AWS_61` | `terraform/aws/s3.tf` | 80 | Ensure that an S3 bucket has a lifecycle configuration |
| HIGH | Checkov | `CKV2_AWS_62` | `terraform/aws/ec2.tf` | 268 | Ensure S3 buckets should have event notifications enabled |
| HIGH | Checkov | `CKV2_AWS_62` | `terraform/aws/s3.tf` | 1 | Ensure S3 buckets should have event notifications enabled |
| HIGH | Checkov | `CKV2_AWS_62` | `terraform/aws/s3.tf` | 110 | Ensure S3 buckets should have event notifications enabled |
| HIGH | Checkov | `CKV2_AWS_62` | `terraform/aws/s3.tf` | 141 | Ensure S3 buckets should have event notifications enabled |
| HIGH | Checkov | `CKV2_AWS_62` | `terraform/aws/s3.tf` | 49 | Ensure S3 buckets should have event notifications enabled |
| HIGH | Checkov | `CKV2_AWS_62` | `terraform/aws/s3.tf` | 80 | Ensure S3 buckets should have event notifications enabled |
| HIGH | Checkov | `CKV2_AWS_64` | `terraform/aws/kms.tf` | 1 | Ensure KMS key Policy is defined |
| HIGH | Checkov | `CKV2_AWS_69` | `terraform/aws/db-app.tf` | 1 | Ensure AWS RDS database instance configured with encryption in transit |
| HIGH | Checkov | `CKV2_AWS_8` | `terraform/aws/rds.tf` | 1 | Ensure that RDS clusters has backup plan of AWS Backup |
| HIGH | Checkov | `CKV2_AWS_8` | `terraform/aws/rds.tf` | 103 | Ensure that RDS clusters has backup plan of AWS Backup |
| HIGH | Checkov | `CKV2_AWS_8` | `terraform/aws/rds.tf` | 120 | Ensure that RDS clusters has backup plan of AWS Backup |
| HIGH | Checkov | `CKV2_AWS_8` | `terraform/aws/rds.tf` | 138 | Ensure that RDS clusters has backup plan of AWS Backup |
| HIGH | Checkov | `CKV2_AWS_8` | `terraform/aws/rds.tf` | 18 | Ensure that RDS clusters has backup plan of AWS Backup |
| HIGH | Checkov | `CKV2_AWS_8` | `terraform/aws/rds.tf` | 35 | Ensure that RDS clusters has backup plan of AWS Backup |
| HIGH | Checkov | `CKV2_AWS_8` | `terraform/aws/rds.tf` | 52 | Ensure that RDS clusters has backup plan of AWS Backup |
| HIGH | Checkov | `CKV2_AWS_8` | `terraform/aws/rds.tf` | 69 | Ensure that RDS clusters has backup plan of AWS Backup |
| HIGH | Checkov | `CKV2_AWS_8` | `terraform/aws/rds.tf` | 86 | Ensure that RDS clusters has backup plan of AWS Backup |
| HIGH | Checkov | `CKV_AWS_101` | `terraform/aws/neptune.tf` | 1 | Ensure Neptune logging is enabled |
| HIGH | Checkov | `CKV_AWS_109` | `terraform/aws/es.tf` | 30 | Ensure IAM policies does not allow permissions management / resource exposure without constraints |
| HIGH | Checkov | `CKV_AWS_111` | `terraform/aws/es.tf` | 30 | Ensure IAM policies does not allow write access without constraints |
| HIGH | Checkov | `CKV_AWS_115` | `terraform/aws/lambda.tf` | 32 | Ensure that AWS Lambda function is configured for function-level concurrent execution limit |
| HIGH | Checkov | `CKV_AWS_116` | `terraform/aws/lambda.tf` | 32 | Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ) |
| HIGH | Checkov | `CKV_AWS_117` | `terraform/aws/lambda.tf` | 32 | Ensure that AWS Lambda function is configured inside a VPC |
| HIGH | Checkov | `CKV_AWS_118` | `terraform/aws/db-app.tf` | 1 | Ensure that enhanced monitoring is enabled for Amazon RDS instances |
| HIGH | Checkov | `CKV_AWS_126` | `terraform/aws/db-app.tf` | 253 | Ensure that detailed monitoring is enabled for EC2 instances |
| HIGH | Checkov | `CKV_AWS_126` | `terraform/aws/ec2.tf` | 1 | Ensure that detailed monitoring is enabled for EC2 instances |
| HIGH | Checkov | `CKV_AWS_127` | `terraform/aws/elb.tf` | 2 | Ensure that Elastic Load Balancer(s) uses SSL certificates provided by AWS Certificate Manager |
| HIGH | Checkov | `CKV_AWS_129` | `terraform/aws/db-app.tf` | 1 | Ensure that respective logs of Amazon Relational Database Service (Amazon RDS) are enabled |
| HIGH | Checkov | `CKV_AWS_130` | `terraform/aws/eks.tf` | 62 | Ensure VPC subnets do not assign public IP by default |
| HIGH | Checkov | `CKV_AWS_130` | `terraform/aws/eks.tf` | 90 | Ensure VPC subnets do not assign public IP by default |
| HIGH | Checkov | `CKV_AWS_133` | `terraform/aws/rds.tf` | 1 | Ensure that RDS instances has backup policy |
| HIGH | Checkov | `CKV_AWS_135` | `terraform/aws/db-app.tf` | 253 | Ensure that EC2 is EBS optimized |
| HIGH | Checkov | `CKV_AWS_135` | `terraform/aws/ec2.tf` | 1 | Ensure that EC2 is EBS optimized |
| HIGH | Checkov | `CKV_AWS_137` | `terraform/aws/es.tf` | 1 | Ensure that Elasticsearch is configured inside a VPC |
| HIGH | Checkov | `CKV_AWS_139` | `terraform/aws/rds.tf` | 1 | Ensure that RDS clusters have deletion protection enabled |
| HIGH | Checkov | `CKV_AWS_139` | `terraform/aws/rds.tf` | 103 | Ensure that RDS clusters have deletion protection enabled |
| HIGH | Checkov | `CKV_AWS_139` | `terraform/aws/rds.tf` | 120 | Ensure that RDS clusters have deletion protection enabled |
| HIGH | Checkov | `CKV_AWS_139` | `terraform/aws/rds.tf` | 138 | Ensure that RDS clusters have deletion protection enabled |
| HIGH | Checkov | `CKV_AWS_139` | `terraform/aws/rds.tf` | 18 | Ensure that RDS clusters have deletion protection enabled |
| HIGH | Checkov | `CKV_AWS_139` | `terraform/aws/rds.tf` | 35 | Ensure that RDS clusters have deletion protection enabled |
| HIGH | Checkov | `CKV_AWS_139` | `terraform/aws/rds.tf` | 52 | Ensure that RDS clusters have deletion protection enabled |
| HIGH | Checkov | `CKV_AWS_139` | `terraform/aws/rds.tf` | 69 | Ensure that RDS clusters have deletion protection enabled |
| HIGH | Checkov | `CKV_AWS_139` | `terraform/aws/rds.tf` | 86 | Ensure that RDS clusters have deletion protection enabled |
| HIGH | Checkov | `CKV_AWS_144` | `terraform/aws/ec2.tf` | 268 | Ensure that S3 bucket has cross-region replication enabled |
| HIGH | Checkov | `CKV_AWS_144` | `terraform/aws/s3.tf` | 1 | Ensure that S3 bucket has cross-region replication enabled |
| HIGH | Checkov | `CKV_AWS_144` | `terraform/aws/s3.tf` | 110 | Ensure that S3 bucket has cross-region replication enabled |
| HIGH | Checkov | `CKV_AWS_144` | `terraform/aws/s3.tf` | 141 | Ensure that S3 bucket has cross-region replication enabled |
| HIGH | Checkov | `CKV_AWS_144` | `terraform/aws/s3.tf` | 49 | Ensure that S3 bucket has cross-region replication enabled |
| HIGH | Checkov | `CKV_AWS_144` | `terraform/aws/s3.tf` | 80 | Ensure that S3 bucket has cross-region replication enabled |
| HIGH | Checkov | `CKV_AWS_157` | `terraform/aws/db-app.tf` | 1 | Ensure that RDS instances have Multi-AZ enabled |
| HIGH | Checkov | `CKV_AWS_161` | `terraform/aws/db-app.tf` | 1 | Ensure RDS database has IAM authentication enabled |
| HIGH | Checkov | `CKV_AWS_162` | `terraform/aws/rds.tf` | 1 | Ensure RDS cluster has IAM authentication enabled |
| HIGH | Checkov | `CKV_AWS_162` | `terraform/aws/rds.tf` | 103 | Ensure RDS cluster has IAM authentication enabled |
| HIGH | Checkov | `CKV_AWS_162` | `terraform/aws/rds.tf` | 120 | Ensure RDS cluster has IAM authentication enabled |
| HIGH | Checkov | `CKV_AWS_162` | `terraform/aws/rds.tf` | 138 | Ensure RDS cluster has IAM authentication enabled |
| HIGH | Checkov | `CKV_AWS_162` | `terraform/aws/rds.tf` | 18 | Ensure RDS cluster has IAM authentication enabled |
| HIGH | Checkov | `CKV_AWS_162` | `terraform/aws/rds.tf` | 35 | Ensure RDS cluster has IAM authentication enabled |
| HIGH | Checkov | `CKV_AWS_162` | `terraform/aws/rds.tf` | 52 | Ensure RDS cluster has IAM authentication enabled |
| HIGH | Checkov | `CKV_AWS_162` | `terraform/aws/rds.tf` | 69 | Ensure RDS cluster has IAM authentication enabled |
| HIGH | Checkov | `CKV_AWS_162` | `terraform/aws/rds.tf` | 86 | Ensure RDS cluster has IAM authentication enabled |
| HIGH | Checkov | `CKV_AWS_186` | `terraform/aws/s3.tf` | 30 | Ensure S3 bucket Object is encrypted by KMS using a customer managed Key (CMK) |
| HIGH | Checkov | `CKV_AWS_189` | `terraform/aws/ec2.tf` | 32 | Ensure EBS Volume is encrypted by KMS using a customer managed Key (CMK) |
| HIGH | Checkov | `CKV_AWS_18` | `terraform/aws/ec2.tf` | 268 | Ensure the S3 bucket has access logging enabled |
| HIGH | Checkov | `CKV_AWS_18` | `terraform/aws/s3.tf` | 1 | Ensure the S3 bucket has access logging enabled |
| HIGH | Checkov | `CKV_AWS_18` | `terraform/aws/s3.tf` | 141 | Ensure the S3 bucket has access logging enabled |
| HIGH | Checkov | `CKV_AWS_18` | `terraform/aws/s3.tf` | 49 | Ensure the S3 bucket has access logging enabled |
| HIGH | Checkov | `CKV_AWS_18` | `terraform/aws/s3.tf` | 80 | Ensure the S3 bucket has access logging enabled |
| HIGH | Checkov | `CKV_AWS_226` | `terraform/aws/db-app.tf` | 1 | Ensure DB instance gets all minor upgrades automatically |
| HIGH | Checkov | `CKV_AWS_228` | `terraform/aws/es.tf` | 1 | Verify Elasticsearch domain is using an up to date TLS policy |
| HIGH | Checkov | `CKV_AWS_23` | `terraform/aws/db-app.tf` | 117 | Ensure every security group and rule has a description |
| HIGH | Checkov | `CKV_AWS_23` | `terraform/aws/db-app.tf` | 136 | Ensure every security group and rule has a description |
| HIGH | Checkov | `CKV_AWS_23` | `terraform/aws/db-app.tf` | 145 | Ensure every security group and rule has a description |
| HIGH | Checkov | `CKV_AWS_247` | `terraform/aws/es.tf` | 1 | Ensure all data stored in the Elasticsearch is encrypted with a CMK |
| HIGH | Checkov | `CKV_AWS_248` | `terraform/aws/es.tf` | 1 | Ensure that Elasticsearch is not using the default Security Group |
| HIGH | Checkov | `CKV_AWS_272` | `terraform/aws/lambda.tf` | 32 | Ensure AWS Lambda function is configured to validate code-signing |
| HIGH | Checkov | `CKV_AWS_273` | `terraform/aws/iam.tf` | 1 | Ensure access is controlled through SSO and not AWS IAM defined users |
| HIGH | Checkov | `CKV_AWS_279` | `terraform/aws/neptune.tf` | 41 | Ensure Neptune snapshot is securely encrypted |
| HIGH | Checkov | `CKV_AWS_280` | `terraform/aws/neptune.tf` | 41 | Ensure Neptune snapshot is encrypted by KMS using a customer managed Key (CMK) |
| HIGH | Checkov | `CKV_AWS_283` | `terraform/aws/es.tf` | 30 | Ensure no IAM policies documents allow ALL or any AWS principal permissions to the resource |
| HIGH | Checkov | `CKV_AWS_293` | `terraform/aws/db-app.tf` | 1 | Ensure that AWS database instances have deletion protection enabled |
| HIGH | Checkov | `CKV_AWS_313` | `terraform/aws/rds.tf` | 1 | Ensure RDS cluster configured to copy tags to snapshots |
| HIGH | Checkov | `CKV_AWS_313` | `terraform/aws/rds.tf` | 103 | Ensure RDS cluster configured to copy tags to snapshots |
| HIGH | Checkov | `CKV_AWS_313` | `terraform/aws/rds.tf` | 120 | Ensure RDS cluster configured to copy tags to snapshots |
| HIGH | Checkov | `CKV_AWS_313` | `terraform/aws/rds.tf` | 138 | Ensure RDS cluster configured to copy tags to snapshots |
| HIGH | Checkov | `CKV_AWS_313` | `terraform/aws/rds.tf` | 18 | Ensure RDS cluster configured to copy tags to snapshots |
| HIGH | Checkov | `CKV_AWS_313` | `terraform/aws/rds.tf` | 35 | Ensure RDS cluster configured to copy tags to snapshots |
| HIGH | Checkov | `CKV_AWS_313` | `terraform/aws/rds.tf` | 52 | Ensure RDS cluster configured to copy tags to snapshots |
| HIGH | Checkov | `CKV_AWS_313` | `terraform/aws/rds.tf` | 69 | Ensure RDS cluster configured to copy tags to snapshots |
| HIGH | Checkov | `CKV_AWS_313` | `terraform/aws/rds.tf` | 86 | Ensure RDS cluster configured to copy tags to snapshots |
| HIGH | Checkov | `CKV_AWS_317` | `terraform/aws/es.tf` | 1 | Ensure Elasticsearch Domain Audit Logging is enabled |
| HIGH | Checkov | `CKV_AWS_318` | `terraform/aws/es.tf` | 1 | Ensure Elasticsearch domains are configured with at least three dedicated master nodes for HA |
| HIGH | Checkov | `CKV_AWS_324` | `terraform/aws/rds.tf` | 1 | Ensure that RDS Cluster log capture is enabled |
| HIGH | Checkov | `CKV_AWS_324` | `terraform/aws/rds.tf` | 103 | Ensure that RDS Cluster log capture is enabled |
| HIGH | Checkov | `CKV_AWS_324` | `terraform/aws/rds.tf` | 120 | Ensure that RDS Cluster log capture is enabled |
| HIGH | Checkov | `CKV_AWS_324` | `terraform/aws/rds.tf` | 138 | Ensure that RDS Cluster log capture is enabled |
| HIGH | Checkov | `CKV_AWS_324` | `terraform/aws/rds.tf` | 18 | Ensure that RDS Cluster log capture is enabled |
| HIGH | Checkov | `CKV_AWS_324` | `terraform/aws/rds.tf` | 35 | Ensure that RDS Cluster log capture is enabled |
| HIGH | Checkov | `CKV_AWS_324` | `terraform/aws/rds.tf` | 52 | Ensure that RDS Cluster log capture is enabled |
| HIGH | Checkov | `CKV_AWS_324` | `terraform/aws/rds.tf` | 69 | Ensure that RDS Cluster log capture is enabled |
| HIGH | Checkov | `CKV_AWS_324` | `terraform/aws/rds.tf` | 86 | Ensure that RDS Cluster log capture is enabled |
| HIGH | Checkov | `CKV_AWS_325` | `terraform/aws/rds.tf` | 1 | Ensure that RDS Cluster audit logging is enabled for MySQL engine |
| HIGH | Checkov | `CKV_AWS_325` | `terraform/aws/rds.tf` | 103 | Ensure that RDS Cluster audit logging is enabled for MySQL engine |
| HIGH | Checkov | `CKV_AWS_325` | `terraform/aws/rds.tf` | 120 | Ensure that RDS Cluster audit logging is enabled for MySQL engine |
| HIGH | Checkov | `CKV_AWS_325` | `terraform/aws/rds.tf` | 138 | Ensure that RDS Cluster audit logging is enabled for MySQL engine |
| HIGH | Checkov | `CKV_AWS_325` | `terraform/aws/rds.tf` | 18 | Ensure that RDS Cluster audit logging is enabled for MySQL engine |
| HIGH | Checkov | `CKV_AWS_325` | `terraform/aws/rds.tf` | 35 | Ensure that RDS Cluster audit logging is enabled for MySQL engine |
| HIGH | Checkov | `CKV_AWS_325` | `terraform/aws/rds.tf` | 52 | Ensure that RDS Cluster audit logging is enabled for MySQL engine |
| HIGH | Checkov | `CKV_AWS_325` | `terraform/aws/rds.tf` | 69 | Ensure that RDS Cluster audit logging is enabled for MySQL engine |
| HIGH | Checkov | `CKV_AWS_325` | `terraform/aws/rds.tf` | 86 | Ensure that RDS Cluster audit logging is enabled for MySQL engine |
| HIGH | Checkov | `CKV_AWS_326` | `terraform/aws/rds.tf` | 1 | Ensure that RDS Aurora Clusters have backtracking enabled |
| HIGH | Checkov | `CKV_AWS_326` | `terraform/aws/rds.tf` | 103 | Ensure that RDS Aurora Clusters have backtracking enabled |
| HIGH | Checkov | `CKV_AWS_326` | `terraform/aws/rds.tf` | 120 | Ensure that RDS Aurora Clusters have backtracking enabled |
| HIGH | Checkov | `CKV_AWS_326` | `terraform/aws/rds.tf` | 138 | Ensure that RDS Aurora Clusters have backtracking enabled |
| HIGH | Checkov | `CKV_AWS_326` | `terraform/aws/rds.tf` | 18 | Ensure that RDS Aurora Clusters have backtracking enabled |
| HIGH | Checkov | `CKV_AWS_326` | `terraform/aws/rds.tf` | 35 | Ensure that RDS Aurora Clusters have backtracking enabled |
| HIGH | Checkov | `CKV_AWS_326` | `terraform/aws/rds.tf` | 52 | Ensure that RDS Aurora Clusters have backtracking enabled |
| HIGH | Checkov | `CKV_AWS_326` | `terraform/aws/rds.tf` | 69 | Ensure that RDS Aurora Clusters have backtracking enabled |
| HIGH | Checkov | `CKV_AWS_326` | `terraform/aws/rds.tf` | 86 | Ensure that RDS Aurora Clusters have backtracking enabled |
| HIGH | Checkov | `CKV_AWS_327` | `terraform/aws/rds.tf` | 1 | Ensure RDS Clusters are encrypted using KMS CMKs |
| HIGH | Checkov | `CKV_AWS_327` | `terraform/aws/rds.tf` | 103 | Ensure RDS Clusters are encrypted using KMS CMKs |
| HIGH | Checkov | `CKV_AWS_327` | `terraform/aws/rds.tf` | 120 | Ensure RDS Clusters are encrypted using KMS CMKs |
| HIGH | Checkov | `CKV_AWS_327` | `terraform/aws/rds.tf` | 138 | Ensure RDS Clusters are encrypted using KMS CMKs |
| HIGH | Checkov | `CKV_AWS_327` | `terraform/aws/rds.tf` | 18 | Ensure RDS Clusters are encrypted using KMS CMKs |
| HIGH | Checkov | `CKV_AWS_327` | `terraform/aws/rds.tf` | 35 | Ensure RDS Clusters are encrypted using KMS CMKs |
| HIGH | Checkov | `CKV_AWS_327` | `terraform/aws/rds.tf` | 52 | Ensure RDS Clusters are encrypted using KMS CMKs |
| HIGH | Checkov | `CKV_AWS_327` | `terraform/aws/rds.tf` | 69 | Ensure RDS Clusters are encrypted using KMS CMKs |
| HIGH | Checkov | `CKV_AWS_327` | `terraform/aws/rds.tf` | 86 | Ensure RDS Clusters are encrypted using KMS CMKs |
| HIGH | Checkov | `CKV_AWS_347` | `terraform/aws/neptune.tf` | 1 | Ensure Neptune is encrypted by KMS using a customer managed Key (CMK) |
| HIGH | Checkov | `CKV_AWS_356` | `terraform/aws/es.tf` | 30 | Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions |
| HIGH | Checkov | `CKV_AWS_359` | `terraform/aws/neptune.tf` | 1 | Neptune DB clusters should have IAM database authentication enabled |
| HIGH | Checkov | `CKV_AWS_361` | `terraform/aws/neptune.tf` | 1 | Ensure that Neptune DB cluster has automated backups enabled with adequate retention |
| HIGH | Checkov | `CKV_AWS_362` | `terraform/aws/neptune.tf` | 1 | Neptune DB clusters should be configured to copy tags to snapshots |
| HIGH | Checkov | `CKV_AWS_376` | `terraform/aws/elb.tf` | 2 | Ensure AWS Elastic Load Balancer listener uses TLS/SSL |
| HIGH | Checkov | `CKV_AWS_37` | `terraform/aws/eks.tf` | 118 | Ensure Amazon EKS control plane logging is enabled for all log types |
| HIGH | Checkov | `CKV_AWS_382` | `terraform/aws/db-app.tf` | 145 | Ensure no security groups allow egress from 0.0.0.0:0 to port -1 |
| HIGH | Checkov | `CKV_AWS_38` | `terraform/aws/eks.tf` | 118 | Ensure Amazon EKS public endpoint not accessible to 0.0.0.0/0 |
| HIGH | Checkov | `CKV_AWS_39` | `terraform/aws/eks.tf` | 118 | Ensure Amazon EKS public endpoint disabled |
| HIGH | Checkov | `CKV_AWS_44` | `terraform/aws/neptune.tf` | 1 | Ensure Neptune storage is securely encrypted |
| HIGH | Checkov | `CKV_AWS_50` | `terraform/aws/lambda.tf` | 32 | X-Ray tracing is enabled for Lambda |
| HIGH | Checkov | `CKV_AWS_58` | `terraform/aws/eks.tf` | 118 | Ensure EKS Cluster has Secrets Encryption Enabled |
| HIGH | Checkov | `CKV_AWS_5` | `terraform/aws/es.tf` | 1 | Ensure all data stored in the Elasticsearch is securely encrypted at rest |
| HIGH | Checkov | `CKV_AWS_79` | `terraform/aws/db-app.tf` | 253 | Ensure Instance Metadata Service Version 1 is not enabled |
| HIGH | Checkov | `CKV_AWS_79` | `terraform/aws/ec2.tf` | 1 | Ensure Instance Metadata Service Version 1 is not enabled |
| HIGH | Checkov | `CKV_AWS_84` | `terraform/aws/es.tf` | 1 | Ensure Elasticsearch Domain Logging is enabled |
| HIGH | Checkov | `CKV_AWS_8` | `terraform/aws/db-app.tf` | 253 | Ensure all data stored in the Launch configuration or instance Elastic Blocks Store is securely encrypted |
| HIGH | Checkov | `CKV_AWS_8` | `terraform/aws/ec2.tf` | 1 | Ensure all data stored in the Launch configuration or instance Elastic Blocks Store is securely encrypted |
| HIGH | Checkov | `CKV_AWS_92` | `terraform/aws/elb.tf` | 2 | Ensure the ELB has access logging enabled |
| HIGH | Checkov | `CKV_AWS_96` | `terraform/aws/rds.tf` | 1 | Ensure all data stored in Aurora is securely encrypted at rest |
| HIGH | Checkov | `CKV_AWS_96` | `terraform/aws/rds.tf` | 103 | Ensure all data stored in Aurora is securely encrypted at rest |
| HIGH | Checkov | `CKV_AWS_96` | `terraform/aws/rds.tf` | 120 | Ensure all data stored in Aurora is securely encrypted at rest |
| HIGH | Checkov | `CKV_AWS_96` | `terraform/aws/rds.tf` | 138 | Ensure all data stored in Aurora is securely encrypted at rest |
| HIGH | Checkov | `CKV_AWS_96` | `terraform/aws/rds.tf` | 18 | Ensure all data stored in Aurora is securely encrypted at rest |
| HIGH | Checkov | `CKV_AWS_96` | `terraform/aws/rds.tf` | 35 | Ensure all data stored in Aurora is securely encrypted at rest |
| HIGH | Checkov | `CKV_AWS_96` | `terraform/aws/rds.tf` | 52 | Ensure all data stored in Aurora is securely encrypted at rest |
| HIGH | Checkov | `CKV_AWS_96` | `terraform/aws/rds.tf` | 69 | Ensure all data stored in Aurora is securely encrypted at rest |
| HIGH | Checkov | `CKV_AWS_96` | `terraform/aws/rds.tf` | 86 | Ensure all data stored in Aurora is securely encrypted at rest |
| HIGH | Checkov | `CKV_DOCKER_2` | `terraform/aws/resources/Dockerfile` | 1 | Ensure that HEALTHCHECK instructions have been added to container images |
| HIGH | Checkov | `CKV_DOCKER_3` | `terraform/aws/resources/Dockerfile` | 1 | Ensure that a user for the container has been created |
