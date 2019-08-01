terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "sans-servers"

    workspaces {
      name = "std-aws-vpc"
    }
  }
}

provider "aws" {
  region  = "${var.region}"
  profile = "serverless-admin"
}

################################################################################
# My IP
data "http" "ip" {
  url = "https://ifconfig.co/"
}

#################################################################################
# Tag stuff so we can see it in the resource group
resource "aws_resourcegroups_group" "tf" {
  name = "std-aws-rg"
  description = "std-aws resources"
  resource_query {
    query = <<END
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "Repo",
      "Values": [
        "std-aws"
      ]
    }
  ]
}
END
  }
}

################################################################################
# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> v2.0"

  name = "${var.vpc_name}"
  cidr = "10.100.0.0/16"

  azs = [
    "${var.region}a",
    "${var.region}b",
  ]
  public_subnets = [
    "10.100.0.0/22",
    "10.100.12.0/22",
  ]
  database_subnets = [
    "10.100.4.0/24",
    "10.100.16.0/24",
  ]

  create_database_subnet_group = true
  create_database_subnet_route_table = true
  create_database_internet_gateway_route = true
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Terraform = "true"
    Repo = "std-aws"
  }
}

################################################################################
# Lambda functions
resource "aws_security_group" "lambda-sg" {
  name = "lambda-sg"
  description = "Add to Lambda for whitelisting by pg-sg"
  vpc_id = "${module.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform = "true"
    Repo = "std-aws"
    Name = "lambda-sg"
  }
}

################################################################################
# Postgres databases
resource "aws_security_group" "pg-sg" {
  name = "pg-sg"
  description = "inbound connections to Postgres databases"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port    = 5432
    to_port      = 5432
    protocol     = "tcp"
    security_groups = [
      "${aws_security_group.lambda-sg.id}"
    ]
  }

  ingress {
    from_port    = 5432
    to_port      = 5432
    protocol     = "tcp"
    cidr_blocks = [
      "${chomp(data.http.ip.body)}/32"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Terraform = "true"
    Repo = "std-aws"
    Name = "pg-sg"
  }
}
