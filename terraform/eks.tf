resource "aws_eks_cluster" "eks_cluster" {
  name     = "react-app-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = aws_subnet.public[*].id
  }

  depends_on = [aws_iam_role.eks_role]
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}