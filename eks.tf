provider "aws" {
  region = "us-east-1"
  alias  = "application"

  assume_role {
    role_arn = "arn:aws:iam::848509689070:role/AWSControlTowerExecution"
  }
}

data "aws_vpc" "landing_zone_vpc" {
  filter {
    name   = "tag:Name"
    values = ["landing-zone-vpc"]  # ✅ Update this if VPC name differs
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.landing_zone_vpc.id]
  }

  filter {
    name   = "tag:Tier"
    values = ["Private"]  # ✅ Fetch only private subnets
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "react-app-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.private_subnets.ids  # ✅ Uses private subnets
  }

  tags = {
    Environment = "production"
  }

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-worker-nodes"
  node_role_arn   = aws_iam_role.eks_worker_role.arn

  subnet_ids = data.aws_subnets.private_subnets.ids  # ✅ Ensure worker nodes are in private subnets

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  instance_types = ["t3.medium"]

  tags = {
    Environment = "production"
  }
}