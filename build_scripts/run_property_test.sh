#!/bin/bash

#
# @author Merve Gulmez 
# @copyright © Ericsson AB 2025
# 
# SPDX-License-Identifier: Apache License, Version 2.0
#

set -euo pipefail

ELF_DIR="${BLINDED_SW_ROOT}/benchmarks/property_test"
SIM="${TOOOBA_ROOT}/builds/RV64ACDFIMSUxCHERI_Toooba_bluesim"
Tests=(
    blinded_global
    blinded_stack
    blinded_malloc
)

cd "${SIM}"

for t in "${Tests[@]}"; do
    ELF_FILE="${ELF_DIR}/${t}.elf"
    LOG_FILE="${ELF_DIR}/blackout_${t}.log"

    # Convert ELF to HEX
    ${TOOOBA_ROOT}/Tests/elf_to_hex/elf_to_hex "${ELF_FILE}" "${SIM}/Mem.hex" >/dev/null 2>&1

    # Run simulation and save log
    ${SIM_BLACKOUT} +tohost &> "${LOG_FILE}"

    # Extract the last 'tohost' value
    TOHOST_VAL=$(grep -E "mmioPlatform.rl_tohost" "${LOG_FILE}" | tail -n1 | awk '{print $NF}')

    # Check result
    if [ "${TOHOST_VAL}" = "18446744073709551615" ]; then
        echo "RESULT: PASS" >> "${LOG_FILE}"
        echo "[$t] ❌ blinded test failed"
    else
        echo "RESULT: FAIL" >> "${LOG_FILE}"
        echo "[$t] ✅ Blinded test passed"
    fi
done
