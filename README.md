
### BLINDED-CHERI-SW

This repository contains a bare-metal testing environment for the **BESSPIN-GFE** platform on **VCU-118** hardware and the **Bluespec simulator**.

More Information

- BLACKOUT: Data-Oblivious Computation with Blinded Capabilities  
  https://arxiv.org/pdf/2504.14654

- Blog post: Making Software Both Memory-Safe and Speculation-Safe  
  https://blog.ssg.aalto.fi/2025/10/making-software-both-memory-safe-and.html


```bibtex
@inproceedings{ElAtali25,
  title = {{BLACKOUT}: {Data-Oblivious Computation} with {Blinded Capabilities}},
  booktitle = {Proceedings of the 2025 {{ACM SIGSAC Conference}} on {{Computer}} and {{Communications Security}} ({{CCS}} '25)},
  author = {ElAtali, Hossam and G{\"u}lmez, Merve and Nyman, Thomas and Asokan, N.},
  year = {2025},
  month = oct,
  publisher = {ACM CCS'25},
  address = {Taipei, Taiwan},
  doi = {10.1145/3719027.3765169},
}
```


### Benchmark Sources

- [crypto](./benchmarks/crypto/): Imported and adapted from the [ProSpect paper
  repository](https://github.com/proteus-core/prospect)

- [spectre](./benchmarks/spectretest/): Imported from the [CTSRD-CHERI Test Suite for Transient Execution](
  https://github.com/CTSRD-CHERI/Test-Suite-Transient-Execution)

- [risc_oblivious](./benchmarks/risc_oblivious_blinded/): Imported from the [OISA repository](https://github.com/cwfletcher/oisa)

- [non-interference-test](./build_scripts/run-security-evaluation.sh) is imported from the [Libra Evaluation](https://github.com/proteus-core/libra/blob/main/libra-eval/run-security-evaluation.sh)


### Compile Options

| Option       | Description |
|--------------|-------------|
| `TLSF=1`     | Enables integration with the TLSF memory allocator, ported from: https://github.com/secure-rewind-and-discard/libtlsf |
| `FPGA=1`     | Builds the project for FPGA environments. For simulation, use FPGA=0. |
| `SPEC=1`     | Required for running Spectre tests due to specific alignment requirements. |
| `CORE_FILES` | Specifies which application(s) to run. Accepts either a list or a single file. |
| `OUT`        | Defines the output ELF file name. |

---

Example Usage:

```
make PORT_DIR=riscv-bare-metal \
    GFE_TARGET=P3 \
    POINTER_SPACE=16 \
    SPEC=0 \
    TOOLCHAIN=LLVM \
    CHERI=1 \
    TLSF=1 \
    CORE_FILES="$BLINDED_SW_ROOT/benchmarks/property_test/blinded_global.c" \
    OUT=blinded_global;
```

---

## Disclaimer

This repository is cloned from the BESSIPIN-coremark repository.  
Original source:  
https://github.com/bessipin/coremark  
(See `Original_README.md` for more details.)

---
License:
Changes to original repo is subject to

© Ericsson AB 2025

© SSG 2025

Apache License, Version 2.0