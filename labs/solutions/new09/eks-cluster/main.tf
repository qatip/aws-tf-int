provider "aws" {
  region = var.region
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_security_group" "cloud9" {
  filter {
    name   = "group-name"
    values = ["aws-cloud9-*"]
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name = "eks-${random_string.suffix.result}"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name                    = local.cluster_name
  cluster_version                 = "1.33"
  cluster_endpoint_public_access  = true

  vpc_id     = var.vpc_id
  subnet_ids = data.aws_subnets.all.ids

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    default = {
      name           = "ng-default"
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }

  node_security_group_additional_rules = {
    allow_cloud9_https = {
      type                     = "ingress"
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      source_security_group_id = data.aws_security_group.cloud9.id
      description              = "Allow Cloud9 to access EKS endpoint"
    }
  }

  access_entries = {
    awsstudent = {
      principal_arn = "arn:aws:iam::568504012673:user/awsstudent"
      user_name     = "awsstudent-admin"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}
