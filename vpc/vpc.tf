module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "1.66.0"

  name = "${local.vpc_name}"
  cidr = "10.100.0.0/16"

  azs = [
    "${local.region}a",
    "${local.region}b",
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
  create_database_internet_gateway_route = false
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Terraform = "true"
  }
}

output "vpc" {
  value =<<END

vpc=${module.vpc.vpc_id}
public_subnets=${join(",", module.vpc.public_subnets)}
database_subnets=${join(",", module.vpc.database_subnets)}
database_subnet_group=${module.vpc.database_subnet_group}

END
}
