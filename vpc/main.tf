terraform {
  backend "s3" {}
}

locals {
  region = "us-east-1"
  vpc_name = "std-vpc"
}

provider "aws" {
  region  = "${local.region}"
}
