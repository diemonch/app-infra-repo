provider "aws" {
  region = "us-east-1"
  alias  = "networking"

  assume_role {
    role_arn = "arn:aws:iam::848509689070:role/AWSControlTowerExecution"
  }
}

# 🎯 Create VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "landing-zone-vpc"
  }
}

# 🎯 Internet Gateway for Public Subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-internet-gateway"
  }
}

# 🎯 NAT Gateway for Private Subnets
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
}

# 🎯 Public Subnets
resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.eks_vpc.id
  cidr_block = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-subnet-${count.index}"
    Tier = "Public"
  }
}

# 🎯 Private Subnets
resource "aws_subnet" "private" {
  count = 2
  vpc_id = aws_vpc.eks_vpc.id
  cidr_block = element(["10.0.3.0/24", "10.0.4.0/24"], count.index)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)

  tags = {
    Name = "eks-private-subnet-${count.index}"
    Tier = "Private"
  }
}

# 🎯 Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# 🎯 Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

# 🎯 Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count = 2
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 🎯 Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  count = 2
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}