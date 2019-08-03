################################################################################
# credentials
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

resource "random_string" "dbsuffix" {
  length = 8
  special = false
  number = true
  upper = false
  lower = true
}

locals {
  db_host = "${data.aws_ssm_parameter.sls-db-host.value}"
  db_port = "${data.aws_ssm_parameter.sls-db-port.value}"
  db_user = "urw${random_string.dbuser.result}"
  db_pass = "${random_string.dbpass.result}"
  db_name = "${var.db_name}-${random_string.dbsuffix.result}-db"
}

################################################################################
locals {
  db_rw_role = "${local.db_name}-rw-role"
  db_ro_role = "${local.db_name}-ro-role"
}

resource "postgresql_role" "rw" {
  name = "${local.db_rw_role}"
  login = false
  inherit = false
  skip_reassign_owned = true
}

resource "postgresql_role" "ro" {
  name = "${local.db_ro_role}"
  login = false
  inherit = false
  skip_reassign_owned = true
}

# the primary database user, who is also the owner of the
# database we just created.
resource "postgresql_role" "dbuser" {
  name = "${local.db_user}"
  password = "${local.db_pass}"
  login = true
  inherit = true
  skip_reassign_owned = true
  roles = [
    "${local.db_rw_role}",
    "${local.db_ro_role}",
  ]
  depends_on = [
    "postgresql_role.rw",
    "postgresql_role.ro",
  ]
}

resource "postgresql_role" "rou" {
  name = "${local.db_name}-rou"
  password = "${local.db_pass}"
  login = true
  inherit = true
  skip_reassign_owned = true
  roles = [
    "${local.db_ro_role}",
  ]
  depends_on = [
    "postgresql_role.ro",
  ]
}


################################################################################
# create the database
resource "postgresql_database" "db" {
  name = "${local.db_name}"
  template = "template1"
  lc_collate = "DEFAULT"
  encoding = "DEFAULT"
  lc_ctype = "DEFAULT"
  owner = "${local.db_user}"
  allow_connections = true

  depends_on = [
    "postgresql_role.dbuser"
  ]
}

################################################################################
# set up permissions
# https://aws.amazon.com/blogs/database/managing-postgresql-users-and-roles/
# https://dba.stackexchange.com/questions/17790/created-user-can-access-all-databases-in-postgresql-without-any-grants

resource "null_resource" "db_setup" {
  provisioner "local-exec" {

    command = <<END
psql --command="
ALTER SCHEMA public OWNER TO \"${local.db_user}\";
--REVOKE ALL ON DATABASE \"${local.db_name}\" FROM public;
"
END

    environment = {
      PGHOST = "${var.db_host}"
      PGPORT = "${var.db_port}"
      PGUSER = "${data.aws_ssm_parameter.sls-db-admin-user.value}"
      PGPASSWORD = "${data.aws_ssm_parameter.sls-db-admin-pass.value}"
      PGDATABASE = "${local.db_name}"
    }
  }

  depends_on = [
    "postgresql_role.rw",
    "postgresql_role.ro",
    "postgresql_role.dbuser",
    "postgresql_database.db",
  ]
}

resource "null_resource" "db_setup_defaults" {
  provisioner "local-exec" {

    command = <<END
psql --command="
REVOKE ALL ON DATABASE \"${local.db_name}\" FROM public;

---- ro role
GRANT CONNECT ON DATABASE \"${local.db_name}\" TO \"${local.db_ro_role}\";
GRANT USAGE ON SCHEMA public TO \"${local.db_ro_role}\";

ALTER DEFAULT PRIVILEGES FOR ROLE \"${local.db_ro_role}\"
GRANT SELECT ON TABLES TO \"${local.db_ro_role}\";

ALTER DEFAULT PRIVILEGES FOR ROLE \"${local.db_ro_role}\"
GRANT SELECT ON SEQUENCES TO \"${local.db_ro_role}\";

--ALTER DEFAULT PRIVILEGES FOR ROLE \"${local.db_ro_role}\"
--GRANT EXECUTE ON FUNCTIONS TO \"${local.db_ro_role}\";

ALTER DEFAULT PRIVILEGES FOR ROLE \"${local.db_ro_role}\"
GRANT USAGE ON TYPES TO \"${local.db_ro_role}\";

ALTER DEFAULT PRIVILEGES FOR ROLE \"${local.db_ro_role}\"
GRANT USAGE ON SCHEMAS TO \"${local.db_ro_role}\";

---- rw role
GRANT CONNECT ON DATABASE \"${local.db_name}\" TO \"${local.db_rw_role}\";
GRANT ALL ON SCHEMA public TO \"${local.db_rw_role}\";

ALTER DEFAULT PRIVILEGES
GRANT ALL ON TABLES TO \"${local.db_rw_role}\";

ALTER DEFAULT PRIVILEGES
GRANT ALL ON SEQUENCES TO \"${local.db_rw_role}\";

ALTER DEFAULT PRIVILEGES
GRANT ALL ON FUNCTIONS TO \"${local.db_rw_role}\";

ALTER DEFAULT PRIVILEGES
GRANT ALL ON TYPES TO \"${local.db_rw_role}\";

ALTER DEFAULT PRIVILEGES
GRANT ALL ON SCHEMAS TO \"${local.db_rw_role}\";
"
END

    environment = {
      PGHOST = "${var.db_host}"
      PGPORT = "${var.db_port}"
      PGUSER = "${local.db_user}"
      PGPASSWORD = "${local.db_pass}"
      #PGUSER = "${data.aws_ssm_parameter.sls-db-admin-user.value}"
      #PGPASSWORD = "${data.aws_ssm_parameter.sls-db-admin-pass.value}"
      PGDATABASE = "${local.db_name}"
    }
  }

  depends_on = [
    "postgresql_role.rw",
    "postgresql_role.ro",
    "postgresql_role.dbuser",
    "postgresql_database.db",
    "null_resource.db_setup",
  ]
}
