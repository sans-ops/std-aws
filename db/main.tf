terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "sans-servers"

    workspaces {
      name = "std-aws-db"
    }
  }
}

provider "aws" {
  region  = "${var.region}"
  profile = "serverless-admin"
}

################################################################################
# database setup
resource "random_string" "dbuser" {
  length = 14
  special = false
  number = false
  upper = false
  lower = true
}

resource "random_string" "dbpass" {
  length = 128
  special = false
  number = true
  upper = true
  lower = true
}

locals {
  db_identifier = "sls"
  db_name = "slsdb"
  db_user = "upg${random_string.dbuser.result}"
  db_pass = "${random_string.dbpass.result}"
  db_port = 5432
  db_version = "11.4"
  db_family = "postgres11"
  instance_class = "db.t2.micro"
}

module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> v2.0"

  identifier = "${local.db_identifier}"

  engine = "postgres"
  engine_version    = "${local.db_version}"
  instance_class    = "${local.instance_class}"
  allocated_storage = 10

  name     = "${local.db_name}"
  username = "${local.db_user}"
  password = "${local.db_pass}"
  port     = "${local.db_port}"

  vpc_security_group_ids = "${split(",", data.aws_ssm_parameter.sls-pg-sg-id.value)}"
  publicly_accessible = true

  db_subnet_group_name = "${data.aws_ssm_parameter.sls-db-subnet-group-name.value}"
  family = "${local.db_family}"
  deletion_protection = false

  iam_database_authentication_enabled = false

  maintenance_window = "Sun:07:00-Sun:07:30"
  backup_window      = "03:00-06:00"
  auto_minor_version_upgrade = true

  create_db_instance = true
  create_db_option_group = false
  create_db_parameter_group = true
  create_db_subnet_group = false
  create_monitoring_role = false

  parameters = [
    {
      name = "ssl"
      value = "1"
    },
    {
      name = "rds.force_ssl"
      value = "1"
    },
  ]

  tags = {
    Terraform = true
    Repo = "std-aws"
  }
}

################################################################################
# set up template1
# https://stackoverflow.com/questions/45394458/how-to-apply-sql-scripts-on-rds-with-terraform
# https://wiki.postgresql.org/wiki/Shared_Database_Hosting#template1
locals {
  setup_dbs = [
    "postgres",
    "template1",
    "${local.db_name}",
  ]
}
resource "null_resource" "db_setup" {
  count = length(local.setup_dbs)

  provisioner "local-exec" {

    command = <<END
psql --command="
  REVOKE ALL ON DATABASE ${element(local.setup_dbs, count.index)} FROM public;
  REVOKE ALL ON SCHEMA public FROM public;
  GRANT ALL ON SCHEMA public TO ${local.db_user};
"
END

    environment = {
      PGHOST = "${module.db.this_db_instance_address}"
      PGPORT = "${local.db_port}"
      PGUSER = "${local.db_user}"
      PGPASSWORD = "${local.db_pass}"
      PGDATABASE = element(local.setup_dbs, count.index)
    }
  }

  depends_on = [
    "module.db",
  ]
}
