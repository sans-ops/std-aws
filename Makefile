init plan create:
	$(MAKE) -C vpc $@
	$(MAKE) -C db $@

delete:
	-$(MAKE) -C db $@
	-$(MAKE) -C vpc $@
