resource "random_id" "dbpass" {
  byte_length = 64
}

locals {
  dbname = "sls"
  dbuser = "postgres"
  dbport = 5432
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "vt-child-tf"
    key = "vpc/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "my-lock-table"
  }
}

module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "1.28.0"

  identifier = "${local.dbname}"

  engine = "postgres"
  engine_version    = "11.2"
  instance_class    = "db.t2.micro"
  allocated_storage = 10

  name     = "${local.dbname}"
  username = "${local.dbuser}"
  password = "${random_id.dbpass.hex}"
  port     = "${local.dbport}"

  vpc_security_group_ids = [
    "${data.terraform_remote_state.vpc.pg_security_group_id}"
  ]
  publicly_accessible = true

  db_subnet_group_name = "${data.terraform_remote_state.vpc.db_subnet_group_name}"
  family = "postgres11"
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

  tags = {
    Terraform = true
  }
}

output "dbinfo" {
  value =<<END

dbname = ${local.dbname}
dbuser = ${local.dbuser}
dbpass = ${random_id.dbpass.hex}
dbhost = ${module.db.this_db_instance_address}
dbport = ${local.dbport}

database_url = postgres://${local.dbuser}:${random_id.dbpass.hex}@${module.db.this_db_instance_address}/${local.dbname}

psql = PGHOST=${module.db.this_db_instance_address} PGUSER=${local.dbuser} PGPASSWORD=${random_id.dbpass.hex} PGDATABASE=${local.dbname} PGPORT=${local.dbport} psql


END
}
