output "dbinfo" {
  value =<<END

dbname = ${local.db_name}
dbuser = ${local.db_user}
dbpass = ${local.db_pass}
dbhost = ${module.db.this_db_instance_address}
dbport = ${local.db_port}

END
}

output "database_url" {
  value = "postgres://${local.db_user}:${local.db_pass}@${module.db.this_db_instance_address}/${local.db_name}"
}

output "psql_cmd" {
  value = "PGHOST=${module.db.this_db_instance_address} PGUSER=${local.db_user} PGPASSWORD=${local.db_pass} PGDATABASE=${local.db_name} PGPORT=${local.db_port} psql"
}

resource "aws_ssm_parameter" "db-host" {
  name = "${var.stack_name}-db-host"
  type = "String"
  value = "${module.db.this_db_instance_address}"

  tags = {
    Terraform = true
    Stack = "${var.stack_name}"
    Repo = "${local.repo}"
  }
}

resource "aws_ssm_parameter" "db-port" {
  name = "${var.stack_name}-db-port"
  type = "String"
  value = "${local.db_port}"

  tags = {
    Terraform = true
    Stack = "${var.stack_name}"
    Repo = "${local.repo}"
  }
}

resource "aws_ssm_parameter" "db-admin-user" {
  name = "${var.stack_name}-db-admin-user"
  type = "String"
  value = "${local.db_user}"

  tags = {
    Terraform = true
    Stack = "${var.stack_name}"
    Repo = "${local.repo}"
  }
}

resource "aws_ssm_parameter" "db-admin-pass" {
  name = "${var.stack_name}-db-admin-pass"
  type = "String"
  value = "${local.db_pass}"

  tags = {
    Terraform = true
    Stack = "${var.stack_name}"
    Repo = "${local.repo}"
  }
}
