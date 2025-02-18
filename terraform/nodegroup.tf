provider "aws" {
  region = "us-east-1"
  alias  = "application"

  assume_role {
    role_arn = "arn:aws:iam::848509689070:role/AWSControlTowerExecution"
  }
}

# 🎯 Node Group for EKS
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-worker-nodes"
  node_role_arn   = aws_iam_role.worker_node_role.arn
  subnet_ids      = data.aws_subnets.private_subnets.ids  # ✅ Use Private Subnets

  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  # 🎯 Enables SSH access for debugging (Optional)
  remote_access {
    ec2_ssh_key = "my-eks-key"  # ✅ Replace with your SSH key
  }

  # 🎯 Add Kubernetes Labels for workload selection
  labels = {
    role = "worker"
    env  = "production"
  }

  # 🎯 Add Node Taints (Optional - For workloads that must run on specific nodes)
  taint {
    key    = "dedicated"
    value  = "gpu"
    effect = "NO_SCHEDULE"
  }

  tags = {
    Environment = "production"
  }
}