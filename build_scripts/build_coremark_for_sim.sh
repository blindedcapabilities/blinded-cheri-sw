#!/bin/bash
set -euo pipefail

#
# @author Merve Gulmez 
# @copyright © Ericsson AB 2025
# 
# SPDX-License-Identifier: Apache License, Version 2.0
#

# --- Fancy colors ---
GREEN="\033[1;32m"
RED="\033[1;31m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

# --- Config ---
OUTDIR="./benchmarks/coremark"
LOGDIR="./build_logs"
mkdir -p "$OUTDIR" "$LOGDIR"

CORE_FILES="core_list_join.c core_main.c core_matrix.c core_state.c core_util.c"
COMMON_FLAGS="PORT_DIR=riscv-bare-metal GFE_TARGET=P3 POINTER_SPACE=16 TOOLCHAIN=LLVM FPGA=0 ITERATIONS=1"

# --- Functions ---
build_coremark() {
    local cheri_flag=$1
    local flavor=$2
    local elf_name="coremark_${flavor}.elf"
    local logfile="$LOGDIR/build_${flavor}.log"

    echo -e "${BLUE}[*] Building CoreMark ($flavor)...${NC}"
    start_time=$(date +%s)

    # Clean before build
    make clean > /dev/null 2>&1 || true

    if make $COMMON_FLAGS CHERI="$cheri_flag" CORE_FILES="$CORE_FILES" OUT=coremark \
        >"$logfile" 2>&1; then
        if [[ -f coremark.elf ]]; then
            mv coremark.elf "$OUTDIR/$elf_name"
            end_time=$(date +%s)
            echo -e "${GREEN}[✓] $flavor build complete:${NC} $OUTDIR/$elf_name  (log: $logfile, took $((end_time - start_time))s)"
        else
            echo -e "${RED}[✗] Build finished but coremark.elf not found!${NC}"
            echo -e "${YELLOW}See log: $logfile${NC}"
            exit 1
        fi
    else
        echo -e "${RED}[✗] $flavor build failed!${NC}"
        echo -e "${YELLOW}See log: $logfile${NC}"
        # show last 20 lines for quick context
        tail -n 20 "$logfile"
        exit 1
    fi
}

# --- Main ---
echo -e "${YELLOW}=== CoreMark build script ===${NC}"
build_coremark 1 "purecap"
build_coremark 0 "baseline"
echo -e "${YELLOW}=== All builds finished successfully ===${NC}"
