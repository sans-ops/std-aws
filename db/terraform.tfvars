terragrunt = {
  include = {
    path = "${find_in_parent_folders()}"
  }

  terraform {
    extra_arguments "root_tfvars" {
      commands = ["${get_terraform_commands_that_need_vars()}"]

      required_var_files = [
        # literally _this_ file (env parent dir)
        "${get_parent_tfvars_dir()}/../terraform.tfvars",
      ]
    }
  }
}
