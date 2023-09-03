provider "aws" {
  region  = var.region
  profile = var.profile

  default_tags {
    tags = {
      Environment = "dev"
    }
  }
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name                 = "my-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "example" {
  name       = "example"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "example"
  }
}

resource "aws_security_group" "rds" {
  name        = "example-rds"
  description = "Used in the terraform"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-rds"
  }
}

resource "aws_db_parameter_group" "example" {
  family = "postgres15"
  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "example" {
  identifier                  = "example-postgres-instance"
  instance_class              = "db.t3.micro"
  allocated_storage           = 10
  storage_type                = "gp2"
  apply_immediately           = true
  engine                      = "postgres"
  engine_version              = "15.3"
  username                    = var.db_username
  password                    = var.db_password
  allow_major_version_upgrade = true
  db_subnet_group_name        = aws_db_subnet_group.example.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  parameter_group_name        = aws_db_parameter_group.example.name
  publicly_accessible         = true
  skip_final_snapshot         = true
  backup_retention_period     = 1

  tags = {
    Name = "example-postgres-instance"
  }
}
