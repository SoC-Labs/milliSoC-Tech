include $(SOCLABS_PROJECT_DIR)/millisoc.config

make_project:
	socrates_cli --project millisoc_tech -data ../ --flow AddNewProject

build_nic400:
	socrates_cli --project millisoc_tech -data ../ --flow build.configured.component configuredComponentName=nic400_millisoc_main

build_nic400_periph:
	socrates_cli --project millisoc_tech -data ../ --flow build.configured.component configuredComponentName=nic400_Rx_peripheral

build_cmsdk:
	$(SOCLABS_MILLISOC_TECH_DIR)/tools/build_cmsdk.sh

build_dma350:
	make -C $(SOCLABS_SLDMA350_TECH_DIR) config_dma_axi_millisoc

# Arm CoreSight SoC-400 debug subsystem.
#
# The SoC-400 components are rendered by Arm's standalone `Build_Component`
# tool rather than by Socrates, so that the build does not need a Socrates
# licence.  The Socrates configured-component XMLs under
# millisoc_tech/socrates/soc400/ remain the source of truth for the
# component parameters.
build_soc400:
	$(SOCLABS_MILLISOC_TECH_DIR)/tools/build_soc400.sh

build_m85:
	$(CORTEX_M85_LOGICAL_DIR)/logical/generate -daplite2 $(CORTEX_M85_DAPLITE_DIR) -config $(SOCLABS_MILLISOC_TECH_DIR)/logical/millisoc_subsystems/millisoc_cpu_subsystem/CM85/m85_config.yaml -output $(SOCLABS_MILLISOC_TECH_DIR)/logical/millisoc_subsystems/millisoc_cpu_subsystem/CM85/logical
