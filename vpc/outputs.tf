output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "public_subnets" {
  value = "${join(",", module.vpc.public_subnets)}"
}

output "database_subnets" {
  value = "${join(",", module.vpc.database_subnets)}"
}

output "db_subnet_group_name" {
  value = "${module.vpc.database_subnet_group}"
}

output "lambda_sg_id" {
  value = "${aws_security_group.lambda-sg.id}"
}

output "pg_sg_id" {
  value = "${aws_security_group.pg-sg.id}"
}
