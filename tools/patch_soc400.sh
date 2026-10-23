#!/bin/bash
#-----------------------------------------------------------------------------
# Apply known source fixes to the rendered Arm CoreSight SoC-400 RTL.
#
# The Arm IP delivery ships a small number of defects in the XSLT templates
# that render the configurable components.  They are fixed here (rather than
# in the Arm delivery, which is read only) so that the milliSoC build is
# reproducible from the delivery.
#
# Every patch is applied to a rendered file under $SOCLABS_SOC400_DIR and is
# idempotent.  If the delivery is ever updated, check that the patches still
# apply (the script fails if an expected pattern is not found).
#-----------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=soc400_env.sh
. "${SCRIPT_DIR}/soc400_env.sh"

LOGICAL="${SOCLABS_SOC400_DIR}/logical"

patch_file() {
    local file="$1"
    local from="$2"
    local to="$3"
    local reason="$4"

    if [ ! -f "${file}" ]; then
        echo "ERROR: ${file} not found - run the SoC-400 build first" >&2
        exit 1
    fi

    if grep -qF -- "${from}" "${file}"; then
        # Use a python one-liner so that the pattern is treated literally.
        python3 - "${file}" "${from}" "${to}" <<'PYEOF'
import sys
path, old, new = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, 'r') as f:
    text = f.read()
text = text.replace(old, new)
with open(path, 'w') as f:
    f.write(text)
PYEOF
        echo "PATCHED ${file}"
        echo "         ${reason}"
    elif grep -qF -- "${to}" "${file}"; then
        echo "   OK   ${file} (already patched)"
    else
        echo "ERROR: expected pattern not found in ${file}" >&2
        echo "       looked for: ${from}" >&2
        exit 1
    fi
}

#-----------------------------------------------------------------------------
# 1. cxdapaxiapfsm_1.v
#
#    The XSLT template cxdapaxiapfsm_xmlcfg.v.xsl in the Arm delivery has a
#    stray backtick in front of the RDY localparam:
#        .test_expr   ((fsm_state_int != `RDY) &&
#    The backtick makes the preprocessor look for a macro called RDY, which
#    does not exist, so the file fails to compile when ARM_ASSERT_ON is
#    defined.
#-----------------------------------------------------------------------------
patch_file \
    "${LOGICAL}/cxdapaxiap_1/verilog/cxdapaxiapfsm_1.v" \
    '(fsm_state_int != `RDY)' \
    '(fsm_state_int != RDY)' \
    "stray backtick before the RDY localparam in the Arm XSL template"

echo "=== SoC-400 source patches applied ==="
