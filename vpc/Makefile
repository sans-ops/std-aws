tf = terragrunt

init:
	$(tf) init

plan: init
	$(tf) $@

apply destroy: init
	$(tf) $@ --auto-approve
