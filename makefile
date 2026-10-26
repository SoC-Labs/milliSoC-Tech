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
	@set -eu; \
	test -n "$(ARM_IP_LIBRARY_PATH)" || { echo "ARM_IP_LIBRARY_PATH is not set" >&2; exit 1; }; \
	test -f "$(U85_CONFIG)" || { echo "Missing U85 configuration: $(U85_CONFIG)" >&2; exit 1; }; \
	test -x "$(U85_SOURCE_DIR)/logical/generate" || { echo "Missing licensed U85 generator: $(U85_SOURCE_DIR)/logical/generate" >&2; exit 1; }; \
	perl_path=$$(command -v "$(U85_PERL)") || { echo "U85 Perl executable not found: $(U85_PERL)" >&2; exit 1; }; \
	python_path=$$(command -v "$(U85_PYTHON)") || { echo "U85 Python executable not found: $(U85_PYTHON)" >&2; exit 1; }; \
	"$$perl_path" -e 'require v5.36.0' || { echo "Ethos-U85 generation requires Perl 5.36.0 or newer (set U85_PERL)" >&2; exit 1; }; \
	"$$python_path" -c 'import sys; sys.version_info >= (3, 7) or sys.exit("Ethos-U85 generation requires Python 3.7 or newer")'; \
	temp_dir=$$(mktemp -d); \
	trap 'rm -rf "$$temp_dir"' EXIT; \
	mkdir -p "$$temp_dir/source" "$$temp_dir/output" "$$temp_dir/bin"; \
	cp -a "$(U85_SOURCE_DIR)/logical" "$$temp_dir/source/"; \
	ln -s "$$python_path" "$$temp_dir/bin/python3"; \
	PATH="$$temp_dir/bin:$$PATH" "$$perl_path" "$$temp_dir/source/logical/generate" \
		--config "$(U85_CONFIG)" --output "$$temp_dir/output"; \
	generated_top="$$temp_dir/output/ethosu85/logical/ethosu85/verilog/ETHOSU85_NUM_MACS256.sv"; \
	test -f "$$generated_top" || { echo "U85 generator did not produce the expected 256-MAC top: $$generated_top" >&2; exit 1; }; \
	grep -q 'module ETHOSU85_NUM_MACS256' "$$generated_top"; \
	grep -q 'BUILD_CFG(256)' "$$generated_top"; \
	mkdir -p "$(U85_OUTPUT_DIR)"; \
	cp -a "$$temp_dir/output/ethosu85/." "$(U85_OUTPUT_DIR)/"

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

build_sram_ctrl:
	@$(SIE300_IP_LOGICAL_DIR)/generate --config ./socrates/BP301_SRAM/SHARED_SRAM.yaml --output ./logical/sie300/