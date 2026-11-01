include $(SOCLABS_PROJECT_DIR)/millisoc.config

# The vendor generator requires Perl 5.36+ and Python 3.7+.
# Generate from a temporary copy because it modifies files in its input tree.
U85_CONFIG := $(SOCLABS_MILLISOC_TECH_DIR)/socrates/ethosu85.yaml
U85_SOURCE_DIR := $(ARM_IP_LIBRARY_PATH)/Ethos-U85/ethosu85
U85_OUTPUT_DIR := $(SOCLABS_MILLISOC_TECH_DIR)/logical/ethos_u85
U85_PERL ?= perl
U85_PYTHON ?= python3

make_project:
	socrates_cli --project millisoc_tech -data ../ --flow AddNewProject

build_u85:
	$(U85_SOURCE_DIR)/logical/generate --config $(U85_CONFIG) --output $(U85_OUTPUT_DIR)

build_nic400:
	socrates_cli --project millisoc_tech -data ../ --flow build.configured.component configuredComponentName=nic400_millisoc_main

build_nic400_periph:
	socrates_cli --project millisoc_tech -data ../ --flow build.configured.component configuredComponentName=nic400_Rx_peripheral

build_cmsdk:
	$(SOCLABS_MILLISOC_TECH_DIR)/tools/build_cmsdk.sh

build_dma350:
	make -C $(SOCLABS_SLDMA350_TECH_DIR) config_dma_axi_millisoc

build_mhu:
	socrates_cli --project millisoc_tech -data ../ --flow build.configured.component configuredComponentName=mhu32ae_mx

# Arm CoreSight SoC-400 debug subsystem.
#
# The SoC-400 components are rendered by Arm's standalone `Build_Component`
# tool rather than by Socrates, so that the build does not need a Socrates
# licence.  The Socrates configured-component XMLs under
# millisoc_tech/socrates/soc400/ remain the source of truth for the
# component parameters.
export SOCLABS_SOC400_DIR=$(SOCLABS_MILLISOC_TECH_DIR)/

build_soc400:
	$(SOCLABS_MILLISOC_TECH_DIR)/tools/build_soc400.sh

build_sram_ctrl:
	@$(SIE300_IP_LOGICAL_DIR)/generate --config ./socrates/BP301_SRAM/SHARED_SRAM.yaml --output ./logical/sie300/