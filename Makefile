init plan create:
	$(MAKE) -C vpc $@
	$(MAKE) -C db $@
	$(MAKE) -C app-db $@

delete:
	-$(MAKE) -C app-db $@
	-$(MAKE) -C db $@
	-$(MAKE) -C vpc $@
