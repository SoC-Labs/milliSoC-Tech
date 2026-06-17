

make_project:
	socrates_cli --project millisoc_tech -data ../ --flow AddNewProject

build_nic400:
	socrates_cli --project millisoc_tech -data ../ --flow build.configured.component configuredComponentName=nic400_millisoc_main

build_dma350:
	make -C $(SOCLABS_SLDMA350_TECH_DIR) config_dma_axi_millisoc

build_m85:
	$(ARM_IP_LIBRARY_PATH)/Cortex-M85/AT640-BU-50000-r1p0-00rel0/olympus/logical/generate -daplite2 $(ARM_IP_LIBRARY_PATH)/Cortex-M85/AT640-BU-50000-r1p0-00rel0/daplite2 -config $(SOCLABS_MILLISOC_TECH_DIR)/logical/millisoc_subsystems/millisoc_cpu_subsystem/CM85/m85_config.yaml -output $(SOCLABS_MILLISOC_TECH_DIR)/logical/millisoc_subsystems/millisoc_cpu_subsystem/CM85/logical
