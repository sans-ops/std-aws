terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
}

#variable "pg_security_group_id" {
#  type = "string"
#}
#
#variable "db_subnet_group_name" {
#  type = "string"
#}

variable "region" {
  type = "string"
}
