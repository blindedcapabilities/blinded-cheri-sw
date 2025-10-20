#!/bin/bash

#
# run spec benchmarks
# @author Merve Gulmez 
# @copyright © Ericsson AB 2025
# 
# SPDX-License-Identifier: BSD-2-Clause, Version 2.0
#


# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color (reset)

ELF_DIR="${BLINDED_SW_ROOT}/benchmarks/spectretest"
SIM="${TOOOBA_ROOT}/builds/RV64ACDFIMSUxCHERI_Toooba_bluesim"
Tests=(
       spec_btb_cheri 
       spec_rsb_cheri 
       spec_stl_cheri 
       spec_btb_cheri_blinded 
       spec_rsb_cheri_blinded 
       spec_stl_cheri_blinded
      )


cd ${SIM}
start_time=$(date +%s)
for t in "${Tests[@]}"; do
    echo "[*] Processing $t ..."
    EXAMPLE="${ELF_DIR}/${t}.elf"
    ${TOOOBA_ROOT}/Tests/elf_to_hex/elf_to_hex ${EXAMPLE} ${SIM}/Mem.hex >/dev/null 2>&1
    ${SIM_BLACKOUT} +tohost &> ${ELF_DIR}/${t}.log || true

    last_line=$(tail -n 1 "${ELF_DIR}/${t}.log")
    if [[ "$last_line" == "PASS" ]]; then
        echo -e "    ${RED}[LEAK]${NC} Secret leaked!"
    else
        echo -e "    ${GREEN}[SAFE]${NC} No leak detected."
    fi
done

# Record end time
end_time=$(date +%s)
total_duration=$((end_time - start_time))
total_minutes=$((total_duration / 60))
total_seconds=$((total_duration % 60))
echo "[✓] All tests completed in ${total_minutes}m ${total_seconds}s"