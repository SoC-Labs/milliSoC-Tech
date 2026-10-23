#!/bin/bash
#-----------------------------------------------------------------------------
# Render an Arm CoreSight SoC-400 configurable component.
#
# This is a direct, licence-free equivalent of what Socrates does in
#   socrates_cli --flow build.configured.component configuredComponentName=<name>
#
# Usage:
#   build_soc400_component.sh <component> <cfg_suffix> [PARAM=VALUE ...]
#
#   <component>    e.g. cxdapbusic, cxdapaxiap, cxapbic
#   <cfg_suffix>   configuration name, e.g. 1
#   PARAM=VALUE    additional IP-XACT user parameters, e.g. NUM_MASTER_INTF=4
#
# Output:
#   $SOCLABS_SOC400_DIR/logical/<component>_<cfg_suffix>/{verilog,xml,ipxact,file_list}
#   $SOCLABS_SOC400_DIR/implementation/<component>_<cfg_suffix>/
#-----------------------------------------------------------------------------
set -euo pipefail

if [ $# -lt 2 ]; then
    echo "ERROR: usage: $0 <component> <cfg_suffix> [PARAM=VALUE ...]" >&2
    exit 1
fi

COMP="$1"
CFG="$2"
shift 2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=soc400_env.sh
. "${SCRIPT_DIR}/soc400_env.sh"

IPXACT_DIR="${CSSOC_SHARED}/logical/${COMP}/ipxact"
if [ ! -f "${IPXACT_DIR}/${COMP}.xml" ]; then
    echo "ERROR: no IP-XACT for component '${COMP}' at ${IPXACT_DIR}/${COMP}.xml" >&2
    exit 1
fi

OUT_ROOT="${SOCLABS_SOC400_DIR}"
OUT_COMP="${OUT_ROOT}/logical/${COMP}_${CFG}"

# The build is not incremental: Build_Component refuses to overwrite an
# existing configured IP-XACT.  Remove the previous output so that the
# render is always from scratch and reproducible.
rm -rf "${OUT_COMP}" "${OUT_ROOT}/implementation/${COMP}_${CFG}"
mkdir -p "${OUT_COMP}/ipxact"

# The build must run with cwd = the component's ipxact directory: the
# generator and the XSL renderer use relative paths from there.
cd "${IPXACT_DIR}"

echo "=== Building SoC-400 component ${COMP}_${CFG} ==="
echo "    ipxact : ${IPXACT_DIR}/${COMP}.xml"
echo "    outdir : ${OUT_COMP}"

"${CSSOC_SHARED}/tools/bin/Build_Component" \
    "${IPXACT_DIR}/${COMP}.xml" \
    "${CFG}" \
    "$@" \
    "TARGET_IPXACT_DIRECTORY=${OUT_COMP}/ipxact/../../" \
    "TARGET_DIRECTORY=${OUT_COMP}/../../"

echo "=== Done: ${OUT_COMP} ==="
find "${OUT_COMP}" -type f | sort
