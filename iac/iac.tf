# Infrastructure as Code (IaC) with Terraform for Redshift, VPC, and S3

provider "aws" {
  region = "us-east-1" # region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# subnets
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet"
  }
}

# S3 Buckets
resource "aws_s3_bucket" "redshift_bucket" {
  bucket = "redshift-cluster-bucket"
  acl    = "private"

  tags = {
    Name        = "Redshift S3 Bucket"
    Environment = "Dev"
  }
}

# Security Group
resource "aws_security_group" "redshift_sg" {
  name        = "redshift-sg"
  description = "Security group for Redshift"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Redshift Security Group"
  }
}

# Redshift cluster
resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier       = "redshift-cluster"
  node_type                = "dc2.large" 
  number_of_nodes          = 1 #minimum
  master_username          = "admin"
  master_password          = "Admin12345" # your pass
  database_name            = "mydb"
  port                     = 5439
  cluster_type             = "single-node"
  iam_roles                = [aws_iam_role.redshift_role.arn]
  publicly_accessible      = true
  vpc_security_group_ids   = [aws_security_group.redshift_sg.id]
  skip_final_snapshot      = true

  tags = {
    Name = "Redshift Cluster"
  }
}

# IAM Role Redshift to S3
resource "aws_iam_role" "redshift_role" {
  name = "RedshiftRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "redshift.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "redshift_s3_access" {
  name = "RedshiftS3Access"
  role = aws_iam_role.redshift_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::redshift-cluster-bucket",
        "arn:aws:s3:::redshift-cluster-bucket/*"
      ]
    }
  ]
}
EOF
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "redshift_endpoint" {
  value = aws_redshift_cluster.redshift_cluster.endpoint
}

output "s3_bucket_name" {
  value = aws_s3_bucket.redshift_bucket.bucket
}
