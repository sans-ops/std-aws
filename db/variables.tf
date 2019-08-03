variable "region" {
  type = string
  description = "AWS region"
}

variable "stack_name" {
  type = string
  description = "Name of the stack."
}

variable "rds_instance_identifier" {
  type = string
  description = "Name of the RDS instance"
}
