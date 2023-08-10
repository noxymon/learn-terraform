provider "aws" {
    region = var.region
}

locals {
    cluster_name = "aladinmall-prod"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc-name
  cidr = "10.0.0.0/16"

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Terraform = "true"
    Environment = "prod"
    Creator = "Sena"
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name = local.cluster_name
  cluster_version = "1.27"

  vpc_id = module.vpc.vpc_id
  subnet_ids =module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
  }

  eks_managed_node_groups = {
    aladinmall-svc = {
      name = "apps-service"
      instance_type= ["t3.micro"]

      min_size=2
      max_size=5
      desired_size=3
    }

    infra-am-svc = {
      name = "infra-service"
      instance_type= ["t3.micro"]

      min_size=1
      max_size=2
      desired_size=1
    }
  }

}