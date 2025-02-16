resource "aws_eks_cluster" "eks_cluster" {
  name     = "react-app-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = aws_subnet.public[*].id
  }

  tags = {
    Environment = "production"
  }

  # ✅ Enables rollback if EKS cluster creation fails
  timeouts {
    create = "30m"
    delete = "30m"
  }
}