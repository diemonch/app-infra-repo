resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-worker-nodes"
  node_role_arn   = aws_iam_role.worker_node_role.arn
  subnet_ids      = aws_subnet.public[*].id
  instance_types  = ["t3.medium"]
  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }
}