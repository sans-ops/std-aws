terraform {
  backend "s3" {}
}

locals {
  region = "us-east-1"
}

provider "aws" {
  region  = "${local.region}"
}

variable "vpc_security_group_id" {
  type = "string"
}

variable "db_subnet_group_name" {
  type = "string"
}
