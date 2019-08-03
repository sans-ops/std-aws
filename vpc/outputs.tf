output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

resource "aws_ssm_parameter" "sls-vpc-id" {
  name = "sls-vpc-id"
  type = "String"
  value = "${module.vpc.vpc_id}"
}

output "public_subnets" {
  value = "${join(",", module.vpc.public_subnets)}"
}

resource "aws_ssm_parameter" "sls-public-subnets" {
  name = "sls-public-subnets"
  type = "StringList"
  value = "${join(",", module.vpc.public_subnets)}"
}

output "database_subnets" {
  value = "${join(",", module.vpc.database_subnets)}"
}

resource "aws_ssm_parameter" "sls-database-subnets" {
  name = "sls-database-subnets"
  type = "StringList"
  value = "${join(",", module.vpc.database_subnets)}"
}

output "db_subnet_group_name" {
  value = "${module.vpc.database_subnet_group}"
}

resource "aws_ssm_parameter" "sls-db-subnet-group-name" {
  name = "sls-db-subnet-group-name"
  type = "String"
  value = "${module.vpc.database_subnet_group}"
}

output "lambda_sg_id" {
  value = "${aws_security_group.lambda-sg.id}"
}

resource "aws_ssm_parameter" "sls-lambda-sg-id" {
  name = "sls-lambda-sg-id"
  type = "String"
  value = "${aws_security_group.lambda-sg.id}"
}

output "pg_sg_id" {
  value = "${aws_security_group.pg-sg.id}"
}

resource "aws_ssm_parameter" "sls-pg-sg-id" {
  name = "sls-pg-sg-id"
  type = "String"
  value = "${aws_security_group.pg-sg.id}"
}
