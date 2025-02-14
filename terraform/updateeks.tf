resource "aws_eks_cluster" "eks_cluster" {
  name     = "react-app-cluster"
  role_arn = aws_iam_role.eks_role.arn  # Now this exists ✅

  vpc_config {
    subnet_ids = aws_subnet.public[*].id  # Now this exists ✅
  }

  depends_on = [aws_iam_role.eks_role]
}