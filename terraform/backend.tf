terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"  # 🛑 Replace with your actual S3 bucket name
    key            = "eks-cluster/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}