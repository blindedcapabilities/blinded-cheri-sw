#!/bin/bash

#
# @author Merve Gulmez 
# @copyright © Ericsson AB 2025
# 
# SPDX-License-Identifier: Apache License, Version 2.0
#

ELF_DIR="${BLINDED_SW_ROOT}/benchmarks/binary_search_non_inter"
SIM="${TOOOBA_ROOT}/builds/RV64ACDFIMSUxCHERI_Toooba_bluesim"

set -x
for SUFFIX in 4_X 4_Y; do
    EXAMPLE="$ELF_DIR/binary_search_$SUFFIX.elf"
    echo "running vcd file $EXAMPLE"
    ${TOOOBA_ROOT}/Tests/elf_to_hex/elf_to_hex $EXAMPLE  $SIM/Mem.hex 
    cd  $SIM
    echo "generating vcd file $EXAMPLE"
    ${SIM_BLACKOUT}  -V  +tohost 
    mv dump.vcd  $ELF_DIR/binary_search_$SUFFIX.vcd
done

