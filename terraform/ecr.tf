resource "aws_ecr_repository" "react_app_repo" {
  name         = "react-app"
  force_delete = true  # Optional: Allows Terraform to delete the repo if needed

  image_scanning_configuration {
    scan_on_push = true  # ✅ Automatically scans images for vulnerabilities on push
  }

  tags = {
    Name        = "react-app-ecr"
    Environment = "production"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.react_app_repo.repository_url
}