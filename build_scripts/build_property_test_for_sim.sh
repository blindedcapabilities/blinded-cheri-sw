#!/bin/bash
set -euo pipefail

#
# @author Merve Gulmez 
# @copyright © Ericsson AB 2025
# 
# SPDX-License-Identifier: Apache License, Version 2.0
#

# --- Colors ---
GREEN="\033[1;32m"
RED="\033[1;31m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color



LOG_DIR="$BLINDED_SW_ROOT/build_logs"

mkdir -p "$LOG_DIR"

# --- Paths ---
BENCH_DIR="$BLINDED_SW_ROOT/benchmarks/property_test"

# --- Tools ---
OBJDUMP="$HOME/cheri/output/sdk/bin/riscv64cheri-objdump"

# --- Benchmarks ---
BENCHMARKS=(blinded_global blinded_malloc blinded_stack)

echo -e "${BLUE}Benchmark directory: $BENCH_DIR${NC}"

for bench in "${BENCHMARKS[@]}"; do
    src_file="$BENCH_DIR/$bench.c"
    elf_file="$BENCH_DIR/$bench.elf"
    dump_file="$BENCH_DIR/$bench.dump"
    log_file="$LOG_DIR/${bench}.log"

    if [ ! -f "$src_file" ]; then
        echo -e "${RED}Source file $src_file not found!${NC}"
        exit 1
    fi

    echo -e "${YELLOW}[*] Building $bench...${NC}"
    start_time=$(date +%s)

    make PORT_DIR=riscv-bare-metal \
              GFE_TARGET=P3 \
              POINTER_SPACE=16 \
              SPEC=0 \
              TOOLCHAIN=LLVM \
              CHERI=1 \
              TLSF=1 \
              CORE_FILES="$src_file" \
              OUT="$bench"  >"$log_file" 2>&1;

    mv "$bench.elf" "$BENCH_DIR/"

    echo -e "${YELLOW}[*] Generating disassembly for $bench...${NC}"
    "$OBJDUMP" -d "$elf_file" > "$dump_file"

    end_time=$(date +%s)
    echo -e "${GREEN}[✓] $bench done (took $((end_time - start_time))s)${NC}"
done

echo -e "${GREEN}All benchmarks processed successfully!${NC}"
