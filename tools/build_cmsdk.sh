#!/bin/bash
set -euo pipefail

if [ -z "${ARM_IP_LIBRARY_PATH:-}" ]; then
    echo "ERROR: ARM_IP_LIBRARY_PATH is not set. Source set_env.sh first." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TECH_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUSMATRIX_NAME="cmsdk_ahb_busmatrix_periph"
CMSDK_DIR="${ARM_IP_LIBRARY_PATH}/latest/Corstone-101/logical/cmsdk_ahb_busmatrix"
CONFIG_DIR="${TECH_DIR}/socrates/cmsdk/${BUSMATRIX_NAME}"
CONFIG_FILE="${BUSMATRIX_NAME}_cfg.xml"
OUTPUT_DIR="${TECH_DIR}/logical/cmsdk/logical/${BUSMATRIX_NAME}"
OUTPUT_VERILOG_DIR="${OUTPUT_DIR}/verilog"

if [ ! -f "${CMSDK_DIR}/bin/BuildBusMatrix.pl" ]; then
    echo "ERROR: CMSDK bus matrix generator not found at ${CMSDK_DIR}/bin/BuildBusMatrix.pl" >&2
    exit 1
fi

if [ ! -f "${CONFIG_DIR}/${CONFIG_FILE}" ]; then
    echo "ERROR: CMSDK bus matrix configuration not found at ${CONFIG_DIR}/${CONFIG_FILE}" >&2
    exit 1
fi

mkdir -p "${OUTPUT_DIR}"
STAGE_DIR="$(mktemp -d "${OUTPUT_DIR}/.build.XXXXXX")"
trap 'rm -rf "${STAGE_DIR}"' EXIT
mkdir -p "${STAGE_DIR}/verilog"

echo "=== Building ${BUSMATRIX_NAME} with the CMSDK generator ==="
(
    cd "${CMSDK_DIR}"
    perl bin/BuildBusMatrix.pl \
        -xmldir "${CONFIG_DIR}" \
        -cfg "${CONFIG_FILE}" \
        -tgtdir "${STAGE_DIR}/verilog"
)

GENERATED_DIR="${STAGE_DIR}/verilog/${BUSMATRIX_NAME}"
GENERATED_FILES=(
    cmsdk_ahb_bm_decode_periphs0.v
    cmsdk_ahb_bm_input_stage_periph.v
    cmsdk_ahb_bm_output_arb_periph.v
    cmsdk_ahb_bm_output_stage_periph.v
    cmsdk_ahb_busmatrix_periph_default_slave.v
    cmsdk_ahb_busmatrix_periph_lite.v
    cmsdk_ahb_busmatrix_periph.v
)

for file in "${GENERATED_FILES[@]}"; do
    if [ ! -f "${GENERATED_DIR}/${file}" ]; then
        echo "ERROR: CMSDK generator did not produce ${GENERATED_DIR}/${file}" >&2
        exit 1
    fi
done

mkdir -p "${OUTPUT_VERILOG_DIR}"
for file in "${GENERATED_FILES[@]}"; do
    cp -f "${GENERATED_DIR}/${file}" "${OUTPUT_VERILOG_DIR}/${file}"
done

echo "=== ${BUSMATRIX_NAME} RTL generated in ${OUTPUT_VERILOG_DIR} ==="
