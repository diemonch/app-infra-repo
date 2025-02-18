provider "aws" {
  region = "us-east-1"
  alias  = "application"

  assume_role {
    role_arn = "arn:aws:iam::848509689070:role/AWSControlTowerExecution"
  }
}

# 🎯 Create ECR Repository
resource "aws_ecr_repository" "react_app_repo" {
  name         = "react-app"
  force_delete = true  # ✅ Allows Terraform to delete the repo if needed

  image_scanning_configuration {
    scan_on_push = true  # ✅ Automatically scans images for vulnerabilities
  }

  encryption_configuration {
    encryption_type = "AES256"  # ✅ Enables encryption for security
  }

  tags = {
    Name        = "react-app-ecr"
    Environment = "production"
  }
}

# 🎯 Apply Lifecycle Policy (Delete Old Images)
resource "aws_ecr_lifecycle_policy" "react_app_policy" {
  repository = aws_ecr_repository.react_app_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 14 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 14
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# 🎯 Output Repository URL
output "ecr_repository_url" {
  value = aws_ecr_repository.react_app_repo.repository_url
}

# 🎯 IAM Policy for EKS Worker Nodes to Pull Images
resource "aws_iam_policy" "ecr_read_policy" {
  name        = "ECRReadPolicy"
  description = "Allows EKS worker nodes to pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = aws_ecr_repository.react_app_repo.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

# 🎯 Attach Policy to Worker Node IAM Role
resource "aws_iam_role_policy_attachment" "worker_ecr_policy" {
  role       = aws_iam_role.worker_node_role.name
  policy_arn = aws_iam_policy.ecr_read_policy.arn
}