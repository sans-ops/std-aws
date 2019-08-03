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

resource "aws_ssm_parameter" "sls-db-host" {
  name = "sls-db-host"
  type = "String"
  value = "${module.db.this_db_instance_address}"
}

resource "aws_ssm_parameter" "sls-db-port" {
  name = "sls-db-port"
  type = "String"
  value = "${local.db_port}"
}

resource "aws_ssm_parameter" "sls-db-admin-user" {
  name = "sls-db-admin-user"
  type = "String"
  value = "${local.db_user}"
}

resource "aws_ssm_parameter" "sls-db-admin-pass" {
  name = "sls-db-admin-pass"
  type = "String"
  value = "${local.db_pass}"
}
