#!/bin/bash

#
# @author Merve Gulmez 
# @copyright © Ericsson AB 2025
# 
# SPDX-License-Identifier: Apache License, Version 2.0
#

# Configuration


##### BASELINE #############
# Configuration
BASE_DIR="${BLINDED_SW_ROOT}/benchmarks/binary_search_non_inter"
PORT_DIR="riscv-bare-metal"
GFE_TARGET="P3"
ELF_DEST="${BLINDED_SW_ROOT}/benchmarks/binary_search_non_inter"
mkdir -p "$ELF_DEST"
CHERI=1
TOOLCHAIN="LLVM"

set -e

for SUFFIX in 4_X 4_Y; do
    OUT="binary_search_$SUFFIX"
    COREFILES="binary_search_$SUFFIX.c"
    echo " Building for binary_search_$SUFFIX → $OUT.elf"


    make \
        PORT_DIR=$PORT_DIR \
        GFE_TARGET=$GFE_TARGET \
        CHERI=$CHERI \
        TOOLCHAIN=$TOOLCHAIN \
        CORE_FILES="$BASE_DIR/$COREFILES" \
        OUT=$OUT   > /dev/null 2>&1;
    mv "$OUT.elf" "$ELF_DEST/"
    echo "Done: $OUT.elf"
    echo "--------------------------------------------"
done
