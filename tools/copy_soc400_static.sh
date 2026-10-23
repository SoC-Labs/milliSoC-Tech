#!/bin/bash
#-----------------------------------------------------------------------------
# Copy the static (non-configurable) Arm CoreSight SoC-400 RTL into the
# milliSoC tree.
#
# The SoC-400 delivery contains a mixture of:
#   * "static" components  - cxdapswjdp, cxdapapbap, cxdapahbap.  These are
#     hand-written Verilog and are used verbatim.
#   * "configurable" components - cxdapbusic, cxdapaxiap, cxapbic.  These are
#     rendered from IP-XACT by tools/build_soc400_component.sh.
#
# The static RTL is copied (rather than referenced in place) so that the
# milliSoC compile does not depend on ARM_IP_LIBRARY_PATH being set once the
# copy has run.
#
# Output: $SOCLABS_MILLISOC_TECH_DIR/logical/soc400/static/
#-----------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=soc400_env.sh
. "${SCRIPT_DIR}/soc400_env.sh"

SRC="${CSSOC_SHARED}/logical"
DST="${SOCLABS_SOC400_STATIC_DIR}"

echo "=== Copying SoC-400 static RTL ==="
echo "    from: ${SRC}"
echo "    to  : ${DST}"

mkdir -p "${DST}"

# --- static components -------------------------------------------------------
for comp in cxdapswjdp cxdapapbap cxdapahbap; do
    if [ ! -d "${SRC}/${comp}/verilog" ]; then
        echo "ERROR: ${SRC}/${comp}/verilog not found" >&2
        exit 1
    fi
    mkdir -p "${DST}/${comp}/verilog"
    cp -f "${SRC}/${comp}/verilog/"*.v "${DST}/${comp}/verilog/"
    echo "    ${comp}/verilog : $(ls -1 "${DST}/${comp}/verilog/"*.v | wc -l) files"
done

# --- generic cells ------------------------------------------------------------
mkdir -p "${DST}/models/cells/generic"
cp -f "${SRC}/models/cells/generic/"*.v "${DST}/models/cells/generic/"
echo "    models/cells/generic : $(ls -1 "${DST}/models/cells/generic/"*.v | wc -l) files"

echo "=== Static SoC-400 RTL copied to ${DST} ==="
