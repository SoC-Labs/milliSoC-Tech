#!/bin/bash
#-----------------------------------------------------------------------------
# Build the Arm CoreSight SoC-400 components used by the milliSoC debug
# subsystem.
#
# Two kinds of content are produced:
#
#   1. Static RTL (cxdapswjdp, cxdapapbap + generic cells) copied verbatim
#      from the Arm IP delivery -> logical/soc400/static/
#   2. Configurable components (cxdapbusic, cxdapaxiap, cxapbic) rendered from
#      IP-XACT -> logical/soc400/logical/<component>_<cfg>/
#
# The component configuration lives in the Socrates project under
# millisoc_tech/socrates/soc400/<component>_<cfg>/<component>_<cfg>.xml.
# Those XML files are the single source of truth for the parameters; this
# script reads them and hands the parameters to Arm's `Build_Component`.
#
# Socrates (`socrates_cli --flow build.configured.component`) is only a thin
# wrapper around `Build_Component`, so this script does not need a Socrates
# licence.  The Socrates project files are kept in sync so that a developer
# with a licence can also rebuild through the GUI/CLI.
#
# Usage: build_soc400.sh [component ...]
#        (no arguments => build all components)
#-----------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TECH_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=soc400_env.sh
. "${SCRIPT_DIR}/soc400_env.sh"

SOCRATES_DIR="${TECH_DIR}/socrates/soc400"

#-----------------------------------------------------------------------------
# Extract the component parameters from a Socrates configured-component XML.
# Only <Specification>/<Parameters>/<Parameter> entries are component
# parameters; the <Protocol> level parameters are interface definitions and
# must not be passed to Build_Component.
#-----------------------------------------------------------------------------
soc400_params() {
    local xml="$1"
    python3 - "$xml" <<'PYEOF'
import sys
import xml.etree.ElementTree as ET

root = ET.parse(sys.argv[1]).getroot()
spec = root.find('Specification')
params = spec.find('Parameters') if spec is not None else None
if params is None:
    sys.exit(0)
for p in params.findall('Parameter'):
    name = p.findtext('Name')
    value = p.findtext('Value')
    if name is None:
        continue
    if value is None:
        continue
    print(f"{name}={value}")
PYEOF
}

#-----------------------------------------------------------------------------
# Build one configured component
#-----------------------------------------------------------------------------
build_component() {
    local comp="$1"
    local cfg="$2"
    local xml="${SOCRATES_DIR}/${comp}_${cfg}/${comp}_${cfg}.xml"

    if [ ! -f "${xml}" ]; then
        echo "ERROR: missing component configuration ${xml}" >&2
        exit 1
    fi

    local params=()
    while IFS= read -r line; do
        [ -n "${line}" ] && params+=("${line}")
    done < <(soc400_params "${xml}")

    echo "--- ${comp}_${cfg} : ${#params[@]} parameter(s)"
    "${SCRIPT_DIR}/build_soc400_component.sh" "${comp}" "${cfg}" "${params[@]}" >/dev/null
    echo "--- ${comp}_${cfg} : rendered into ${SOCLABS_SOC400_DIR}/logical/${comp}_${cfg}"
}

#-----------------------------------------------------------------------------
# Main
#-----------------------------------------------------------------------------
COMPONENTS=("$@")
if [ ${#COMPONENTS[@]} -eq 0 ]; then
    COMPONENTS=(cxdapbusic cxdapaxiap cxapbic)
fi

echo "=== Building SoC-400 static RTL ==="
"${SCRIPT_DIR}/copy_soc400_static.sh"

for comp in "${COMPONENTS[@]}"; do
    build_component "${comp}" 1
done

echo "=== Applying known source fixes to the rendered RTL ==="
"${SCRIPT_DIR}/patch_soc400.sh"

echo "=== SoC-400 build complete ==="
find "${SOCLABS_SOC400_DIR}/logical" -maxdepth 2 -mindepth 2 -type d | sort
