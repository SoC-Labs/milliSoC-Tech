#!/bin/bash
#-----------------------------------------------------------------------------
# Environment for building/rendering the Arm CoreSight SoC-400 components
# used by the milliSoC debug subsystem.
#
# The SoC-400 delivery ships its own build tools under
#   $ARM_IP_LIBRARY_PATH/SoC-400/coresight_soc/shared/tools/bin
# The most important of these is `Build_Component`, a standalone Perl script
# that resolves the IP-XACT user parameters and renders the component RTL.
#
# Socrates (`socrates_cli --flow build.configured.component`) is only a thin
# wrapper around `Build_Component`.  We drive `Build_Component` directly so
# that the build does not depend on a Socrates licence being available.
#
# This file is sourced, not executed.
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Locate the SoC-400 delivery
#-----------------------------------------------------------------------------
if [ -z "${ARM_IP_LIBRARY_PATH}" ]; then
    echo "ERROR: ARM_IP_LIBRARY_PATH is not set. Source set_env.sh first." >&2
    return 1 2>/dev/null || exit 1
fi

export CSSOC_ROOT="${ARM_IP_LIBRARY_PATH}/SoC-400/coresight_soc"
if [ ! -d "${CSSOC_ROOT}/shared/tools/bin" ]; then
    echo "ERROR: CoreSight SoC-400 delivery not found at ${CSSOC_ROOT}" >&2
    echo "       (expected ${CSSOC_ROOT}/shared/tools/bin/Build_Component)" >&2
    return 1 2>/dev/null || exit 1
fi

export CSSOC_INSTALL_DIR="${CSSOC_ROOT}/"
export CSSOC_SHARED="${CSSOC_ROOT}/shared"

# IPXACT_lib.pm lives in the shared tools bin directory; Build_Component
# does `use lib "$IPXACT_SHARED"`.
export IPXACT_SHARED="${CSSOC_SHARED}/tools/bin"

#-----------------------------------------------------------------------------
# Third-party tools used by the SoC-400 build
#-----------------------------------------------------------------------------
# The Socrates installation ships the exact tool versions the SoC-400
# delivery was qualified against.  Reuse them rather than the system ones.
_SOCRATES_THIRDPARTY="/apps/ARM-Socrates/etc/thirdparty/ad_3p_tools"

export CSSOC_PERL="${_SOCRATES_THIRDPARTY}/perl_5_8_8/linux/bin/perl"
export CSSOC_XALAN="${_SOCRATES_THIRDPARTY}/xalan_1_8_0/linux/bin/Xalan"
export CSSOC_XERCES="${_SOCRATES_THIRDPARTY}/xercesc_2_5_0/linux/"
export CSSOC_TCL="${_SOCRATES_THIRDPARTY}/tcl_8_4_13/linux/"

# PERL5LIB must contain the third-party perl's site/lib for XML::LibXML.
export PERL5LIB="${_SOCRATES_THIRDPARTY}/perl_5_8_8/linux/lib/:${_SOCRATES_THIRDPARTY}/perl_5_8_8/linux/site/lib/:${CSSOC_SHARED}/tools/bin${PERL5LIB:+:${PERL5LIB}}"

export LD_LIBRARY_PATH="${_SOCRATES_THIRDPARTY}/xalan_1_8_0/linux/lib:${_SOCRATES_THIRDPARTY}/xercesc_2_5_0/linux/lib:${_SOCRATES_THIRDPARTY}/tcl_8_4_13/linux/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

# `build_design.sh` and `render.pl` invoke `Xalan` and `perl` by name.
export PATH="${_SOCRATES_THIRDPARTY}/perl_5_8_8/linux/bin:${_SOCRATES_THIRDPARTY}/xalan_1_8_0/linux/bin:${PATH}"

#-----------------------------------------------------------------------------
# Where the rendered components land
#-----------------------------------------------------------------------------
# Rendered components are written to:
#   $SOCLABS_MILLISOC_TECH_DIR/logical/soc400/logical/<component>_<cfg>/
if [ -z "${SOCLABS_MILLISOC_TECH_DIR}" ]; then
    echo "ERROR: SOCLABS_MILLISOC_TECH_DIR is not set. Source set_env.sh first." >&2
    return 1 2>/dev/null || exit 1
fi
export SOCLABS_SOC400_DIR="${SOCLABS_MILLISOC_TECH_DIR}/logical/soc400"
export SOCLABS_SOC400_STATIC_DIR="${SOCLABS_SOC400_DIR}/static"
