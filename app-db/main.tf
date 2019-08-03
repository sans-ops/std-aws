terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "sans-servers"

    workspaces {
      name = "std-aws-app-db"
    }
  }
}

provider "aws" {
  region  = "${var.region}"
  profile = "serverless-admin"
}

provider "postgresql" {
  alias = "rdspg"
  host = "${data.aws_ssm_parameter.sls-db-host.value}"
  port = "${data.aws_ssm_parameter.sls-db-port.value}"
  database = "postgres"
  username = "${data.aws_ssm_parameter.sls-db-admin-user.value}"
  password = "${data.aws_ssm_parameter.sls-db-admin-pass.value}"
  sslmode = "require"
  connect_timeout = 15
  superuser = false
}

################################################################################
module "app-db" {
  source = "../modules/database"
  db_host = "${data.aws_ssm_parameter.sls-db-host.value}"
  db_port = "${data.aws_ssm_parameter.sls-db-port.value}"
  db_name = "foo"

  providers = {
    postgresql = "postgresql.rdspg"
  }
}

output "app-db-psql" {
  value = "${module.app-db.psql}"
}

output "app-db-database-url" {
  value = "${module.app-db.database-url}"
}

################################################################################
module "app-db1" {
  source = "../modules/database"
  db_host = "${data.aws_ssm_parameter.sls-db-host.value}"
  db_port = "${data.aws_ssm_parameter.sls-db-port.value}"
  db_name = "foo"

  providers = {
    postgresql = "postgresql.rdspg"
  }
}

output "app-db-psql1" {
  value = "${module.app-db1.psql}"
}

output "app-db-database-url1" {
  value = "${module.app-db1.database-url}"
}


output "app-db-rou" {
  value = "${module.app-db1.rou}"
}
