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
module "db-foo" {
  source = "../modules/database"
  db_host = "${data.aws_ssm_parameter.sls-db-host.value}"
  db_port = "${data.aws_ssm_parameter.sls-db-port.value}"
  db_name = "foo"

  providers = {
    postgresql = "postgresql.rdspg"
  }
}

output "db-foo-rw-psql" {
  value = "${module.db-foo.rw-psql}"
}

output "db-foo-rw-database-url" {
  value = "${module.db-foo.rw-database-url}"
}

output "db-foo-ro-psql" {
  value = "${module.db-foo.ro-psql}"
}

output "db-foo-ro-database-url" {
  value = "${module.db-foo.ro-database-url}"
}

################################################################################
module "db-bar" {
  source = "../modules/database"
  db_host = "${data.aws_ssm_parameter.sls-db-host.value}"
  db_port = "${data.aws_ssm_parameter.sls-db-port.value}"
  db_name = "bar"

  providers = {
    postgresql = "postgresql.rdspg"
  }
}

output "db-bar-rw-psql" {
  value = "${module.db-bar.rw-psql}"
}

output "db-bar-rw-database-url" {
  value = "${module.db-bar.rw-database-url}"
}

output "db-bar-ro-psql" {
  value = "${module.db-bar.ro-psql}"
}

output "db-bar-ro-database-url" {
  value = "${module.db-bar.ro-database-url}"
}
