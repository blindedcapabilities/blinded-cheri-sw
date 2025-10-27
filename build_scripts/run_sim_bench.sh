#!/bin/bash

#
# @author Merve Gulmez 
# @copyright © Ericsson AB 2025
# 
# SPDX-License-Identifier: Apache License, Version 2.0
#

set -euo pipefail

ELF_DIR="${BLINDED_SW_ROOT}/benchmarks/risc_oblivious_sim"
SIM="${TOOOBA_ROOT}/builds/RV64ACDFIMSUxCHERI_Toooba_bluesim"

Tests=(
    binary_search_purecap_12
    binary_search_baseline_12
    binary_search_blinded_12
)

# Cycle counters
declare -A cycles

cd "${SIM}"

for t in "${Tests[@]}"; do
    ELF_FILE="${ELF_DIR}/${t}.elf"
    LOG_FILE="${ELF_DIR}/blackout_${t}.log"

    echo "[*] Running $t ..."

    # Convert ELF to HEX
    "${TOOOBA_ROOT}/Tests/elf_to_hex/elf_to_hex" "${ELF_FILE}" "${SIM}/Mem.hex" >/dev/null 2>&1

    # Run simulation and save log
    "${SIM_BLACKOUT}" +tohost &> "${LOG_FILE}"

    # Decide category
    if [[ "$t" == *baseline* ]]; then
        category="baseline"
    elif [[ "$t" == *blinded* ]]; then
        category="blinded"
    elif [[ "$t" == *purecap* ]]; then
        category="purecap"
    else
        category="other"
    fi

    # Extract last numeric field (cycle count)
    cycle_count=$(grep -E "FAIL [0-9]+$" "$LOG_FILE" | tail -n1 | awk '{print $2}')
    cycles["$category"]=$cycle_count

    echo "    [$category] cycles = $cycle_count"
done

echo
echo "===== Summary Ratios ====="
baseline=${cycles[baseline]:-0}
blinded=${cycles[blinded]:-0}
purecap=${cycles[purecap]:-0}

if (( baseline > 0 && blinded > 0 )); then
    ratio=$(awk "BEGIN {printf \"%.2f\", $baseline/$blinded}")
    echo "baseline/blinded = $baseline / $blinded = $ratio"
fi

if (( baseline > 0 && purecap > 0 )); then
    ratio=$(awk "BEGIN {printf \"%.2f\", $baseline/$purecap}")
    echo "baseline/purecap = $baseline / $purecap = $ratio"
fi

if (( blinded > 0 && purecap > 0 )); then
    ratio=$(awk "BEGIN {printf \"%.2f\", $blinded/$purecap}")
    echo "blinded/purecap = $blinded / $purecap = $ratio"
fi
