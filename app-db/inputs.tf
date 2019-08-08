data "aws_ssm_parameter" "sls-db-host" {
  name = "${var.stack_name}-db-host"
}

data "aws_ssm_parameter" "sls-db-port" {
  name = "${var.stack_name}-db-port"
}

data "aws_ssm_parameter" "sls-db-admin-user" {
  name = "${var.stack_name}-db-admin-user"
}

data "aws_ssm_parameter" "sls-db-admin-pass" {
  name = "${var.stack_name}-db-admin-pass"
}
