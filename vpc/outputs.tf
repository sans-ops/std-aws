output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

resource "aws_ssm_parameter" "vpc-id" {
  name = "${var.stack_name}-vpc-id"
  type = "String"
  value = "${module.vpc.vpc_id}"

  tags = {
    Terraform = "true"
    Stack = "${var.stack_name}"
    Repo = "${local.repo}"
  }
}

output "public_subnets" {
  value = "${join(",", module.vpc.public_subnets)}"
}

resource "aws_ssm_parameter" "public-subnets" {
  name = "${var.stack_name}-public-subnets"
  type = "StringList"
  value = "${join(",", module.vpc.public_subnets)}"

  tags = {
    Terraform = "true"
    Stack = "${var.stack_name}"
    Repo = "${local.repo}"
  }
}

output "database_subnets" {
  value = "${join(",", module.vpc.database_subnets)}"
}

resource "aws_ssm_parameter" "database-subnets" {
  name = "${var.stack_name}-database-subnets"
  type = "StringList"
  value = "${join(",", module.vpc.database_subnets)}"

  tags = {
    Terraform = "true"
    Stack = "${var.stack_name}"
    Repo = "${local.repo}"
  }
}

output "db_subnet_group_name" {
  value = "${module.vpc.database_subnet_group}"
}

resource "aws_ssm_parameter" "db-subnet-group-name" {
  name = "${var.stack_name}-db-subnet-group-name"
  type = "String"
  value = "${module.vpc.database_subnet_group}"

  tags = {
    Terraform = "true"
    Stack = "${var.stack_name}"
    Repo = "${local.repo}"
  }
}

output "lambda_sg_id" {
  value = "${aws_security_group.lambdas-sg.id}"
}

resource "aws_ssm_parameter" "lambdas-sg-id" {
  name = "${var.stack_name}-lambdas-sg-id"
  type = "String"
  value = "${aws_security_group.lambdas-sg.id}"

  tags = {
    Terraform = "true"
    Stack = "${var.stack_name}"
    Repo = "${local.repo}"
  }
}

output "pg_sg_id" {
  value = "${aws_security_group.pg-sg.id}"
}

resource "aws_ssm_parameter" "pg-sg-id" {
  name = "${var.stack_name}-pg-sg-id"
  type = "String"
  value = "${aws_security_group.pg-sg.id}"

  tags = {
    Terraform = "true"
    Stack = "${var.stack_name}"
    Repo = "${local.repo}"
  }
}
