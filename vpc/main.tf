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
locals {
  vpc_name = "${var.stack_name}-vpc"
  lambdas_sg_name = "${local.vpc_name}-lambdas-sg"
  pg_sg_name = "${local.vpc_name}-pg-sg"
  repo = "std-aws"
}

################################################################################
# My IP
data "http" "ip" {
  url = "https://ifconfig.co/"
}

#################################################################################
# Tag stuff so we can see it in the resource group
resource "aws_resourcegroups_group" "tf" {
  name = "${local.repo}-${var.stack_name}-rg"
  description = "${local.repo} resources for stack ${var.stack_name}"
  resource_query {
    query = <<END
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "Stack",
      "Values": [
        "${var.stack_name}"
      ]
    },
    {
      "Key": "Repo",
      "Values": [
        "${local.repo}"
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

  name = "${local.vpc_name}"
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
    Stack = "${var.stack_name}"
    Repo = "${local.repo}"
  }
}

################################################################################
# Lambda functions
resource "aws_security_group" "lambdas-sg" {
  name = "${local.lambdas_sg_name}"
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
    Stack = "${var.stack_name}"
    Repo = "${local.repo}"
    Name = "${local.lambdas_sg_name}"
  }
}

################################################################################
# Postgres databases
resource "aws_security_group" "pg-sg" {
  name = "${local.pg_sg_name}"
  description = "inbound connections to Postgres databases"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port    = 5432
    to_port      = 5432
    protocol     = "tcp"
    security_groups = [
      "${aws_security_group.lambdas-sg.id}"
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
    Stack = "${var.stack_name}"
    Repo = "${local.repo}"
    Name = "${local.pg_sg_name}"
  }
}
