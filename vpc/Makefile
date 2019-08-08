include ../config.mk
tf = terraform
vars ?=

init:
	$(tf) init

create update: init
	$(tf) apply --auto-approve $(vars)

delete:
	$(tf) destroy --auto-approve $(vars)

plan output:
	$(tf) $@ $(vars)
