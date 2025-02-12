resource "aws_ecr_repository" "react_app_repo" {
  name                 = "react-app"
  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.react_app_repo.repository_url
}