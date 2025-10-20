
#!/bin/bash

 
#
# build benchmarks
# @author Merve Gulmez 
# @copyright © Ericsson AB 2025
# 
# SPDX-License-Identifier: BSD-2-Clause, Version 2.0
#


set -euo pipefail

BENCH_DIR="$BLINDED_SW_ROOT/benchmarks/spectretest"
LOG_DIR="$BLINDED_SW_ROOT/build_logs"
mkdir -p "$LOG_DIR"

TARGETS=(
    spec_btb_cheri
    spec_rsb_cheri
    spec_stl_cheri
    spec_btb_cheri_blinded
    spec_rsb_cheri_blinded
    spec_stl_cheri_blinded
)

for t in "${TARGETS[@]}"; do
    SRC_FILE="$BENCH_DIR/$t.S"
    OUT_ELF="$BENCH_DIR/$t.elf"
    OUT_DUMP="$BENCH_DIR/$t.dump"
    LOG_FILE="$LOG_DIR/build_${t}.log"

    if [ ! -f "$SRC_FILE" ]; then
        echo "[✗] Source file not found: $SRC_FILE"
        exit 1
    fi

    echo "[*] Building Spectre Test ($t)..."
    start_time=$(date +%s)

    if make \
        PORT_DIR=riscv-bare-metal \
        GFE_TARGET=P3 \
        POINTER_SPACE=16 \
        SPEC=1 \
        TOOLCHAIN=LLVM \
        CHERI=1 \
        CORE_FILES="$SRC_FILE" \
        OUT="$t" \
        >"$LOG_FILE" 2>&1; then

        mv "$t.elf" "$OUT_ELF"
        ~/cheri/output/sdk/bin/riscv64cheri-objdump -d "$OUT_ELF" > "$OUT_DUMP"

        end_time=$(date +%s)
        elapsed=$((end_time - start_time))
        echo "[✓] $t build complete: $OUT_ELF (log: $LOG_FILE, took ${elapsed}s)"
    else
        echo "[✗] Build failed for $t (see $LOG_FILE)"
        exit 1
    fi
done

# make PORT_DIR=riscv-bare-metal GFE_TARGET=P3 POINTER_SPACE=16 SPEC=1 TOOLCHAIN=LLVM CHERI=1 CORE_FILES=$BENCH_DIR/spec_btb_cheri_blinded.S OUT=$BENCH_DIR/spectre_btb_blinded
# make PORT_DIR=riscv-bare-metal GFE_TARGET=P3 POINTER_SPACE=16 SPEC=1 TOOLCHAIN=LLVM CHERI=1 CORE_FILES=$BENCH_DIR/spec_stl_cheri_blinded.S OUT=$BENCH_DIR/spectre_stl_blinded
# make PORT_DIR=riscv-bare-metal GFE_TARGET=P3 POINTER_SPACE=16 SPEC=1 TOOLCHAIN=LLVM CHERI=1 CORE_FILES=$BENCH_DIR/spec_rsb_cheri_blinded.S OUT=$BENCH_DIR/spectre_rsb_blinded
# make PORT_DIR=riscv-bare-metal GFE_TARGET=P3 POINTER_SPACE=16 SPEC=1 TOOLCHAIN=LLVM CHERI=1 CORE_FILES=$BENCH_DIR/spec_btb_cheri.S OUT=$BENCH_DIR/spectre_btb
# make PORT_DIR=riscv-bare-metal GFE_TARGET=P3 POINTER_SPACE=16 SPEC=1 TOOLCHAIN=LLVM CHERI=1 CORE_FILES=$BENCH_DIR/spec_stl_cheri.S OUT=$BENCH_DIR/spectre_stl
# make PORT_DIR=riscv-bare-metal GFE_TARGET=P3 POINTER_SPACE=16 SPEC=1 TOOLCHAIN=LLVM CHERI=1 CORE_FILES=$BENCH_DIR/spec_rsb_cheri.S OUT=$BENCH_DIR/spectre_rsb