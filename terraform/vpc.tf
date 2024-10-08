provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "lambda" {
  name        = "lambda_sg"
  description = "Lambda function security group"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group" "elasticache" {
  name        = "elasticache_sg"
  description = "ElastiCache security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }
}

resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name       = "EleasticacheSubnetGroup"
  subnet_ids = [aws_subnet.private.id]
}

resource "aws_ssm_parameter" "subnet_id" {
  name  = "/node_elasticache_serverless/vpc/private_subnet_id"
  type  = "String"
  value = aws_subnet.private.id
}

resource "aws_ssm_parameter" "vpc_id" {
  name  = "/node_elasticache_serverless/vpc/vpc_id"
  type  = "String"
  value = aws_vpc.main.id
}
