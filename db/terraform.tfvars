terragrunt = {
  include = {
    path = "${find_in_parent_folders()}"
  }
}

vpc_security_group_id = "sg-072f4aa7a4675913f"
db_subnet_group_name = "std-vpc"
