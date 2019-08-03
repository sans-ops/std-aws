data "aws_ssm_parameter" "sls-pg-sg-id" {
  name = "sls-pg-sg-id"
}

data "aws_ssm_parameter" "sls-db-subnet-group-name" {
  name = "sls-db-subnet-group-name"
}
