terragrunt = {
  remote_state {
    backend = "s3"
    config {
      bucket = "vt-child-tf"
      key = "${path_relative_to_include()}/terraform.tfstate"
      region = "us-east-1"
      encrypt = true
      dynamodb_table = "my-lock-table"
    }
  }

  terraform {}
}

vpc_name = "std-vpc"
region = "us-east-1"
#db_subnet_group_name = "std-vpc"
#pg_security_group_id = "sg-02aab15bc165fceee"
