#!/bin/bash

#
# @author Merve Gulmez 
# @copyright © Ericsson AB 2025
# 
# SPDX-License-Identifier: Apache License, Version 2.0
#

##### BASELINE #############
# Configuration
BASE_DIR="/home/merve/cheri/blinded-cheri-sw/benchmarks/synthetic-benchmark"
PORT_DIR="riscv-bare-metal"
GFE_TARGET="P3"
ELF_DEST="/home/merve/cheri/blinded-cheri-sw/spec_bench"
mkdir -p "$ELF_DEST"

CHERI=0
BLINDED=0
TOOLCHAIN="LLVM"
TLSF=1
FPGA=1
XCFLAGS="-I$BASE_DIR/include -I$BASE_DIR/include/kremlib -DPERFORMANCE_RUN=1"

for SUFFIX in 10 25 50 75; do
    SPEC_FILE="$BASE_DIR/specBenchsha_$SUFFIX"
    OUT="sha2_spec_baseline_$SUFFIX"

    echo " Building for specBenchsha_$SUFFIX → $OUT.elf"


    make \
        PORT_DIR=$PORT_DIR \
        GFE_TARGET=$GFE_TARGET \
        CHERI=$CHERI \
        BLINDED=$BLINDED \
        TOOLCHAIN=$TOOLCHAIN \
        TLSF=$TLSF \
        FPGA=$FPGA \
        CORE_FILES="$BASE_DIR/Hacl_Hash_SHA2 $SPEC_FILE" \
        XCFLAGS="$XCFLAGS" \
        OUT=$OUT
    mv "$OUT.elf" "$ELF_DEST/"
    echo "Done: $OUT_noncheri.elf"
    echo "--------------------------------------------"
done


##### CHERI#############
BASE_DIR="/home/merve/cheri/blinded-cheri-sw/benchmarks/synthetic-benchmark"
PORT_DIR="riscv-bare-metal"
GFE_TARGET="P3"
CHERI=1
BLINDED=0
POINTER_SPACE=16
TOOLCHAIN="LLVM"
TLSF=1
FPGA=1
XCFLAGS="-I$BASE_DIR/include -I$BASE_DIR/include/kremlib -DPERFORMANCE_RUN=1"

for SUFFIX in 10 25 50 75; do
    SPEC_FILE="$BASE_DIR/specBenchsha_$SUFFIX"
    OUT="sha2_spec_cheri_$SUFFIX"

    echo "Building for specBenchsha_$SUFFIX → $OUT.elf"


    make \
        PORT_DIR=$PORT_DIR \
        GFE_TARGET=$GFE_TARGET \
        CHERI=$CHERI \
        BLINDED=$BLINDED \
        POINTER_SPACE=$POINTER_SPACE \
        TOOLCHAIN=$TOOLCHAIN \
        TLSF=$TLSF \
        FPGA=$FPGA \
        CORE_FILES="$BASE_DIR/Hacl_Hash_SHA2 $SPEC_FILE" \
        XCFLAGS="$XCFLAGS" \
        OUT=$OUT
    
    mv "$OUT.elf" "$ELF_DEST/"
    echo "Done: $OUT_cheri.elf"
    echo "--------------------------------------------"
done



##### CHERI BLINDED #############
CHERI=1
BLINDED=1
POINTER_SPACE=16
TOOLCHAIN="LLVM"
TLSF=1
FPGA=1
XCFLAGS="-I$BASE_DIR/include -I$BASE_DIR/include/kremlib -DPERFORMANCE_RUN=1"

for SUFFIX in 10 25 50 75; do
    SPEC_FILE="$BASE_DIR/specBenchsha_$SUFFIX"
    OUT="sha2_spec_cheri_blinded_$SUFFIX"

    echo "Building for specBenchsha_$SUFFIX → $OUT.elf"


    make \
        PORT_DIR=$PORT_DIR \
        GFE_TARGET=$GFE_TARGET \
        CHERI=$CHERI \
        POINTER_SPACE=$POINTER_SPACE \
        TOOLCHAIN=$TOOLCHAIN \
        TLSF=$TLSF \
        BLINDED=$BLINDED \
        FPGA=$FPGA \
        CORE_FILES="$BASE_DIR/Hacl_Hash_SHA2 $SPEC_FILE" \
        XCFLAGS="$XCFLAGS" \
        OUT=$OUT
    mv "$OUT.elf" "$ELF_DEST/"
    echo "Done: $OUT_cheri_blinded.elf"
    echo "--------------------------------------------"
done


