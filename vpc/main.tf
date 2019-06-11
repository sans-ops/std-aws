terraform {
  backend "s3" {}
}

variable "region" {
  type = "string"
}

variable "vpc_name" {
  type = "string"
}

provider "aws" {
  region  = "${var.region}"
}
