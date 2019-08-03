data "aws_ssm_parameter" "sls-db-host" {
  name = "sls-db-host"
}

data "aws_ssm_parameter" "sls-db-port" {
  name = "sls-db-port"
}

data "aws_ssm_parameter" "sls-db-admin-user" {
  name = "sls-db-admin-user"
}

data "aws_ssm_parameter" "sls-db-admin-pass" {
  name = "sls-db-admin-pass"
}
