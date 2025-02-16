#!/bin/bash

set -e  # Exit on error

# Initialize Terraform
terraform init

# Apply Terraform Configuration
terraform apply -auto-approve

# Retrieve ECR URL from Terraform Outputs
ECR_URL=$(terraform output -raw ecr_repository_url)

# Authenticate Docker with AWS ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

# Build and Push Docker Image
docker build -t react-app .
docker tag react-app:latest $ECR_URL:latest
docker push $ECR_URL:latest

# Deploy to EKS
aws eks update-kubeconfig --region us-east-1 --name $(terraform output -raw eks_cluster_name)
kubectl set image deployment/react-app react-app=$ECR_URL:latest
kubectl rollout status deployment/react-app