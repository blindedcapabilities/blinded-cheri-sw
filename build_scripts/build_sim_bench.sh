#!/bin/bash

#
# @author Merve Gulmez 
# @copyright © Ericsson AB 2025
# 
# SPDX-License-Identifier: Apache License, Version 2.0
#

# Configuration
set -x

##### BASELINE #############
# Configuration
BASE_DIR="${BLINDED_SW_ROOT}/benchmarks/risc_oblivious_sim"
PORT_DIR="riscv-bare-metal"
GFE_TARGET="P3"
ELF_DEST="${BLINDED_SW_ROOT}/benchmarks/risc_oblivious_sim"
mkdir -p "$ELF_DEST"
CHERI=0
TLSF=1
FPGA=0
BLINDED=0
TOOLCHAIN="LLVM"

set -e

for SUFFIX in 12; do
    OUT="binary_search_baseline_$SUFFIX"
    COREFILES="binary_search_$SUFFIX.c"
    echo " Building for binary_search_$SUFFIX → $OUT.elf"


    make \
        PORT_DIR=$PORT_DIR \
        GFE_TARGET=$GFE_TARGET \
        CHERI=$CHERI \
        TLSF=$TLSF \
        FPGA=$FPGA \
        BLINDED=$BLINDED \
        TOOLCHAIN=$TOOLCHAIN \
        CORE_FILES="$BASE_DIR/$COREFILES" \
        OUT=$OUT 
    mv "$OUT.elf" "$ELF_DEST/"
    echo "Done: $OUT.elf"
    echo "--------------------------------------------"
done



##### BASELINE #############
# Configuration
BASE_DIR="${BLINDED_SW_ROOT}/benchmarks/risc_oblivious_sim"
PORT_DIR="riscv-bare-metal"
GFE_TARGET="P3"
ELF_DEST="${BLINDED_SW_ROOT}/benchmarks/risc_oblivious_sim"
mkdir -p "$ELF_DEST"
CHERI=1
BLINDED=0
TOOLCHAIN="LLVM"

set -e

for SUFFIX in 12; do
    OUT="binary_search_purecap_$SUFFIX"
    COREFILES="binary_search_$SUFFIX.c"
    echo " Building for binary_search_$SUFFIX → $OUT.elf"


    make \
        PORT_DIR=$PORT_DIR \
        GFE_TARGET=$GFE_TARGET \
        CHERI=$CHERI \
        BLINDED=$BLINDED \
        TLSF=$TLSF \
        FPGA=$FPGA \
        TOOLCHAIN=$TOOLCHAIN \
        CORE_FILES="$BASE_DIR/$COREFILES" \
        OUT=$OUT  >/dev/null 2>&1
    mv "$OUT.elf" "$ELF_DEST/"
    echo "Done: $OUT.elf"
    echo "--------------------------------------------"
done



##### BLINDED #############
# Configuration
BASE_DIR="${BLINDED_SW_ROOT}/benchmarks/risc_oblivious_sim"
PORT_DIR="riscv-bare-metal"
GFE_TARGET="P3"
ELF_DEST="${BLINDED_SW_ROOT}/benchmarks/risc_oblivious_sim"
mkdir -p "$ELF_DEST"
CHERI=1
BLINDED=1
TOOLCHAIN="LLVM"


for SUFFIX in 12; do
    OUT="binary_search_blinded_$SUFFIX"
    COREFILES="binary_search_$SUFFIX.c"
    echo " Building for binary_search_$SUFFIX → $OUT.elf"


    make \
        PORT_DIR=$PORT_DIR \
        GFE_TARGET=$GFE_TARGET \
        CHERI=$CHERI \
        TLSF=$TLSF \
        FPGA=$FPGA \
        BLINDED=$BLINDED \
        TOOLCHAIN=$TOOLCHAIN \
        CORE_FILES="$BASE_DIR/$COREFILES" \
        OUT=$OUT   >/dev/null 2>&1
    mv "$OUT.elf" "$ELF_DEST/"
    echo "Done: $OUT.elf"
    echo "--------------------------------------------"
done
