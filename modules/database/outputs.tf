output "db-user" {
  value = "${local.db_user}"
}

output "db-pass" {
  value = "${local.db_pass}"
}

output "db-name" {
  value = "${local.db_name}"
}

output "psql" {
  value = "PGHOST=${var.db_host} PGPORT=${var.db_port} PGUSER=${local.db_user} PGPASSWORD=${local.db_pass} PGDATABASE=${local.db_name} psql"
}

output "rou" {
  value = "PGHOST=${var.db_host} PGPORT=${var.db_port} PGUSER=${local.db_name}-rou PGPASSWORD=${local.db_pass} PGDATABASE=${local.db_name} psql"
}

output "database-url" {
  value = "postgres://${local.db_user}:${local.db_pass}@${var.db_host}:${var.db_port}/${local.db_name}"
}
