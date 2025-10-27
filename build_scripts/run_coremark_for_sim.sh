#!/bin/bash

#
# @author Merve Gulmez 
# @copyright © Ericsson AB 2025
# 
# SPDX-License-Identifier: Apache License, Version 2.0
#

set -euo pipefail

# --- Start timer ---
start_time=$(date +%s)

ELF_DIR="${BLINDED_SW_ROOT}/benchmarks/coremark"
SIM="${TOOOBA_ROOT}/builds/RV64ACDFIMSUxCHERI_Toooba_bluesim"
Tests=(
    coremark_baseline
    coremark_purecap
)

declare -A cycles

cd "${SIM}"

# --- Run with SIM_BLACKOUT (Blinded Toooba) ---
for t in "${Tests[@]}"; do
    LOG_FILE="${ELF_DIR}/blackout_${t}.log"
    ${TOOOBA_ROOT}/Tests/elf_to_hex/elf_to_hex "${ELF_DIR}/${t}.elf" "${SIM}/Mem.hex"
    ${SIM_BLACKOUT} +tohost &> "$LOG_FILE"
    cycles["blackout_${t}"]=$(grep -E "FAIL [0-9]+$" "$LOG_FILE" | tail -n1 | awk '{print $2}')
done

# --- Run with SIM_BASELINE (CHERI-Toooba) ---
for t in "${Tests[@]}"; do
    LOG_FILE="${ELF_DIR}/baseline_${t}.log"
    ${TOOOBA_ROOT}/Tests/elf_to_hex/elf_to_hex "${ELF_DIR}/${t}.elf" "${SIM}/Mem.hex"
    ${SIM_BASELINE} +tohost &> "$LOG_FILE"
    cycles["baseline_${t}"]=$(grep -E "FAIL [0-9]+$" "$LOG_FILE" | tail -n1 | awk '{print $2}')
done

# --- Stop timer ---
end_time=$(date +%s)
elapsed=$(( end_time - start_time ))
minutes=$(( elapsed / 60 ))
seconds=$(( elapsed % 60 ))

# --- Generate summary table ---
echo -e "\n=== CoreMark Performance Summary ==="
printf "%-20s %-15s %-15s %-10s %-10s\n" "Core" "Config" "Total ticks" "Δ" "Overhead"

for core in baseline blackout; do
    base=${cycles["${core}_coremark_baseline"]}
    pure=${cycles["${core}_coremark_purecap"]}
    delta=$(( pure - base ))
    perc=$(awk -v d="$delta" -v b="$base" 'BEGIN { printf "%.2f%%", (d/b)*100 }')

    if [ "$core" == "baseline" ]; then
        core_label="CHERI-Toooba"
    else
        core_label="Blinded CHERI-Toooba"
    fi

    printf "%-20s %-15s %-15s %-10s %-10s\n" "$core_label" "baseline (nocap)" "$base" "-" "-"
    printf "%-20s %-15s %-15s %-10s %-10s\n" "" "purecap" "$pure" "$delta" "$perc"
    echo
done

echo "Total runtime: ${minutes} min ${seconds} sec"
