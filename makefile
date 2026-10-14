include $(SOCLABS_PROJECT_DIR)/millisoc.config

make_project:
	socrates_cli --project millisoc_tech -data ../ --flow AddNewProject

build_nic400:
	socrates_cli --project millisoc_tech -data ../ --flow build.configured.component configuredComponentName=nic400_millisoc_main

build_cmsdk:
	socrates_cli --project millisoc_tech -data ../ --flow build.configured.component configuredComponentName=nic400_millisoc_main


build_dma350:
	make -C $(SOCLABS_SLDMA350_TECH_DIR) config_dma_axi_millisoc

build_m85:
	$(CORTEX_M85_LOGICAL_DIR)/logical/generate -daplite2 $(CORTEX_M85_DAPLITE_DIR) -config $(SOCLABS_MILLISOC_TECH_DIR)/logical/millisoc_subsystems/millisoc_cpu_subsystem/CM85/m85_config.yaml -output $(SOCLABS_MILLISOC_TECH_DIR)/logical/millisoc_subsystems/millisoc_cpu_subsystem/CM85/logical
