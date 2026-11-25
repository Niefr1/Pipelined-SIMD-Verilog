# Pipelined SIMD Multimedia Unit

A 4-stage pipelined SIMD multimedia processor implemented in Verilog. It is a ground-up redo of an earlier VHDL design, with a cleaner architecture, a merged ALU, and fixes for the datapath mistakes in the original.

## Overview

The unit executes packed (SIMD) multimedia operations on wide registers, fetching instructions from an on-chip instruction buffer and running them through a pipeline with data forwarding to resolve hazards. It supports three instruction classes:

- **Load immediate (loadi):** writes an immediate value into a field of a register
- **R3-format:** three-register SIMD operations
- **R4-format:** four-register operations such as multiply-add and multiply-subtract

## Features

- 4-stage pipeline: `[IF / ID / EX / WB, adjust to your stage names]`
- Register file of `[N x W-bit]` registers with `[number]` read ports and `[number]` write port
- Instruction buffer of `[N]` entries, `[W]` bits each
- Single merged multimedia ALU handling R3, R4, and loadi operations
- Load-immediate integrated into the register file write path
- Data forwarding to resolve RAW hazards without unnecessary stalls
- Self-checking testbenches for each module

## Architecture

```
          +--------+     +--------+     +--------+     +--------+
 PC ----> |   IF   | --> |   ID   | --> |   EX   | --> |   WB   |
          | Instr. |     | Reg.   |     | Multi- |     | Reg.   |
          | Buffer |     | File   |     | media  |     | File   |
          |        |     | Read   |     | ALU    |     | Write  |
          +--------+     +--------+     +--------+     +--------+
                              ^              |              |
                              +---- forwarding paths -------+
```

### Modules

| Module | File | Description |
|---|---|---|
| Instruction buffer | `src/instr_buffer.v` | Stores the program and supplies one instruction per cycle |
| Register file | `src/register_file.v` | Multi-port register storage with loadi support |
| Multimedia ALU | `src/multimedia_alu.v` | Merged ALU for R3, R4, and loadi operations |
| Forwarding unit | `src/forwarding_unit.v` | Detects hazards and selects forwarded operands |
| Pipeline registers | `src/pipeline_regs.v` | IF/ID, ID/EX, EX/WB latches |
| Top level | `src/top.v` | Connects all stages |

*(Update the file names to match your repo.)*

## Design Notes

**Redesign from the original VHDL version**

- **Merged ALU.** The original design used separate files for R3, R4, and loadi instructions. These are now one ALU with opcode-based operation selection, which removes duplicated logic and simplifies the datapath.
- **Integrated load-immediate.** Previously, load-immediate was implemented as a separate entity/architecture outside the register file. It is now handled through the register file's normal write path.
- **Corrected datapath issues** identified in the original block diagram (`Pipelined_Multimedia_Unit_Design.drawio`). `[List the specific fixes here.]`

## Instruction Set

| Format | Description | Example operations |
|---|---|---|
| Load immediate | Write an immediate into a register field | `loadi` |
| R3 | `rd = f(rs1, rs2)` | `[add, sub, and, or, shifts, ...]` |
| R4 | `rd = f(rs1, rs2, rs3)` | `[multiply-add, multiply-subtract, ...]` |

*(Add the instruction encoding table and opcode map here.)*

## Getting Started

### Prerequisites

- `[Simulator, e.g. Icarus Verilog / ModelSim / Vivado / Verilator]`
- `[Waveform viewer, e.g. GTKWave]`

### Build and Simulate

```bash
# Example with Icarus Verilog
iverilog -o sim tb/tb_top.v src/*.v
vvp sim
gtkwave dump.vcd
```

### Running a Program

Place your program in `[program.mem / instruction file]`, then run the top-level testbench. The instruction buffer is loaded at simulation start.

## Verification

Each module has its own testbench in `tb/`, and `tb_top.v` runs full programs through the pipeline. Tests cover:

- Register file reads, writes, and
