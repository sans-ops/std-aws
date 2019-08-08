# AWS region
region = us-east-1

# Namespace for this stack.  Also used as prefix
# for Terraform Cloud workspace.
namespace = foo

# Stack name.  You can create multiple stacks
# in one namespace
stack_name = hola

#
# DO NOT CHANGE below this unless you know what you are doing. )
#
vars = \
	-var region=$(region) \
	-var stack_name=$(stack_name)
