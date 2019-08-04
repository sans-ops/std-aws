output "database_url" {
  value = "postgres://${local.db_user}:${local.db_pass}@${module.db.this_db_instance_address}/${local.db_name}"
}

output "psql_cmd" {
  value = "PGHOST=${module.db.this_db_instance_address} PGUSER=${local.db_user} PGPASSWORD=${local.db_pass} PGDATABASE=${local.db_name} PGPORT=${local.db_port} psql"
}

output "db_host" {
  value = "${module.db.this_db_instance_address}"
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

output "db_port" {
  value = "${local.db_port}"
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

output "db_admin_user" {
  value = "${local.db_user}"
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

output "db-admin-pass" {
  value = "xxxxxxxxx"
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
