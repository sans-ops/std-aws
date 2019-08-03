data "aws_ssm_parameter" "pg-sg-id" {
  name = "${var.stack_name}-pg-sg-id"
}

data "aws_ssm_parameter" "db-subnet-group-name" {
  name = "${var.stack_name}-db-subnet-group-name"
}
