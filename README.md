# 11-Stage Pipelined Dual-Issue Sony Cell SPU

A SystemVerilog implementation of a simplified **Sony Cell Synergistic Processing Unit (SPU)**-style processor core. The project models a dual-issue, deeply pipelined execution engine with separate even/odd instruction pipes, 128-bit SIMD-style register data paths, hazard-aware issue logic, branch handling, local-store memory support, and a Python assembler for loading SPU-like assembly programs into simulation.

This repository is written to demonstrate hardware architecture judgment, RTL implementation depth, and end-to-end system thinking: instruction encoding, decode, issue, execute, forwarding, memory, and testbench-driven validation are all represented in a compact processor project.

---

## Why This Project Matters

For engineering managers reviewing my work, this project highlights my ability to:

- Translate a real processor architecture concept into modular RTL.
- Design a pipelined datapath with realistic control-flow and hazard-management concerns.
- Implement both the hardware model and the software tooling needed to exercise it.
- Work across abstraction layers: assembly, instruction encoding, microarchitecture, memories, pipeline registers, forwarding, and verification.
- Build readable, decomposed hardware modules rather than a monolithic simulation model.

---

## Main Features

### Dual-Issue Pipeline

The top-level processor fetches two 32-bit instructions per cycle from instruction memory and attempts to issue them together into the appropriate execution pipes. The program counter advances by 8 bytes on normal operation, reflecting two-instruction fetch granularity.

Key capabilities:

- Two-instruction fetch from instruction memory.
- Even-pipe and odd-pipe instruction classification.
- Single-cycle issue of compatible instruction pairs.
- Selective single issue when hazards or structural conflicts prevent safe dual issue.
- Stop-instruction detection for controlled simulation termination.

### 11-Stage-Oriented Execution Model

The design models deep SPU-like execution latency through an execute subsystem backed by per-pipe packet arrays. The top-level sets `LAST_STAGE = 8` for the execute pipe arrays, while the full design flow includes fetch, decode, and execute/writeback staging to represent an 11-stage processor organization.

Pipeline packet structs carry:

- Source operand values.
- Destination register addresses.
- Instruction IDs.
- Latency metadata.
- Register-write controls.
- Instruction-order metadata for dual-issue bookkeeping.

### Separate Even and Odd Execution Pipes

The Cell SPU architecture groups instructions into even and odd execution classes. This implementation follows that idea by decoding each instruction into an `Instr_type` and routing it through either the even or odd pipe.

Representative responsibilities:

- **Even pipe:** arithmetic, logical, compare, immediate, floating-point, multiply, and other computation-heavy operations.
- **Odd pipe:** local-store access, branches, byte/quadword shifts and rotates, gather operations, and control-flow-oriented operations.

### Hazard Detection and Issue Control

The top-level issue logic checks for hazards before allowing instructions to enter execution. It accounts for dependencies both between the two instructions currently being decoded and against instructions already in the execution pipelines.

Implemented hazard categories include:

- Register-file hazards from instructions entering execute.
- Pipeline hazards against in-flight destination registers.
- Decode-stage dependencies between instruction 1 and instruction 2.
- Structural conflicts such as both issued instructions targeting the same destination register.
- Stall control that preserves fetch/decode state until the hazard clears.

### Forwarding / Bypass Network

The execute module includes forwarding logic that compares source registers against destinations in both even and odd pipeline arrays. When a newer result is available in flight, the operand forwarded to execution is replaced with the pipeline result rather than waiting for register-file writeback.

Forwarded operands include:

- Even pipe: `RA`, `RB`, `RC`, and `RT` source data.
- Odd pipe: `RA`, `RB`, and `RT` source data.
- Results from both even and odd in-flight pipelines.

### Branch Handling and Pipeline Flushes

The odd execution path computes branch target addresses and branch-taken signals for direct, indirect, conditional, and link-style branch instructions. The top-level program counter can redirect to a branch target, and the execute stage exposes branch flush signals to clear younger work when control flow changes.

Branch support includes examples such as:

- Relative and absolute branches.
- Branch-and-set-link forms.
- Indirect branches.
- Conditional zero / not-zero branches.
- Halfword conditional branch variants.

### 128-Bit SIMD-Style Register File

The register file contains 128 registers, each 128 bits wide, matching the broad-vector flavor of the Cell SPU. It supports separate even and odd writeback ports and exposes multiple source operands to the two issue lanes.

Notable characteristics:

- 128 x 128-bit architectural register file.
- Separate write enables for even and odd results.
- Multiple read ports for dual-issue operand fetch.
- Reset initialization of all registers.

### Local Store Memory Model

The `local_store` module models SPU-style local memory access with 128-bit memory entries and quadword load/store behavior. It is initialized with sample floating-point matrix data, making it useful for workloads that exercise vectorized memory operations.

### Python Assembler

The repository includes a Python assembler that converts SPU-like assembly text into hexadecimal machine instructions for the instruction memory.

Assembler features:

- Two-pass label resolution.
- Register parsing and bounds checking.
- Immediate-width validation.
- Branch-offset calculation.
- Encoding support for RR, RRR, RI7, RI10, RI16, RI18, and special instruction formats.
- Output to `instructions.txt`, which is loaded by the SystemVerilog instruction memory.

The assembler currently defines 99 mnemonics across the supported instruction formats, giving the RTL a broad instruction surface to decode and execute.

---

## Repository Structure

| File | Purpose |
| --- | --- |
| `top_level.sv` | Processor integration: fetch, decode, issue, hazard detection, branch redirect, and execute wiring. |
| `decode.sv` | Instruction decoder that maps instruction bit patterns to internal IDs, operand fields, latencies, writeback controls, and even/odd pipe type. |
| `execute.sv` | Execute subsystem wrapper with register-file integration, forwarding, writeback, and branch flush control. |
| `even_execute.sv` | Even-pipe functional unit implementation. |
| `odd_execute.sv` | Odd-pipe functional unit implementation, including branch and local-store-oriented operations. |
| `even_pipe.sv` / `odd_pipe.sv` | Pipeline movement and packet propagation for each execution pipe. |
| `packet_pkg.sv` | Shared packed structs for decoded packets and pipeline packets. |
| `register_file.sv` | 128-register, 128-bit-wide architectural register file. |
| `instruction_memory.sv` | Two-instruction fetch memory backed by `instructions.txt`. |
| `local_store.sv` | 128-bit local-store memory model with sample matrix data. |
| `program_counter.sv` | Program counter register with write enable and reset behavior. |
| `IF_ID_reg.sv` / `ID_EX_reg.sv` | Pipeline registers between fetch/decode and decode/execute. |
| `assembler.py` | Python assembler for SPU-like assembly input. |
| `assembly.txt` | Default assembly source consumed by the assembler. |
| `instructions.txt` | Hex instruction image consumed by instruction memory. |
| `top_level_tb.sv` | Full-system simulation testbench. |
| `pipeline_tb.sv` | Lower-level pipeline-oriented testbench. |
| `expected_output.txt` | Human-readable expected behavior notes for sample instructions. |

---

## Architecture Overview

```text
assembly.txt
    |
    v
assembler.py  --->  instructions.txt
                         |
                         v
                  instruction_memory
                         |
                         v
                  IF/ID pipeline register
                         |
                         v
                    decode_stage x2
                         |
          +--------------+--------------+
          | hazard / issue / routing    |
          +--------------+--------------+
                         |
                         v
                  ID/EX pipeline register
                         |
                         v
       +-----------------+-----------------+
       |                                   |
       v                                   v
  even execution pipe                 odd execution pipe
       |                                   |
       +-----------------+-----------------+
                         |
                         v
             forwarding + writeback
                         |
                         v
                 128 x 128-bit register file
```

---

## Instruction Support

The implementation uses internal instruction IDs for a broad subset of SPU-like operations. Supported categories include:

- Integer arithmetic and subtract forms.
- Logical operations and immediate logical operations.
- Compare equal / greater-than operations.
- Immediate load forms.
- Shifts and rotates across halfwords, words, bytes, and quadwords.
- Floating-point add, subtract, multiply, fused multiply-add, and fused multiply-subtract.
- Multiply and multiply-accumulate forms.
- Gather and count operations.
- Quadword loads and stores.
- Relative, absolute, indirect, conditional, and link branches.
- NOP, load-NOP, and stop instructions.

The assembler instruction table is organized by binary instruction format:

| Format | Count | Examples |
| --- | ---: | --- |
| RR | 38 | `a`, `and`, `xor`, `fa`, `mpy`, `lqx`, `stqx` |
| RRR | 3 | `fma`, `fms`, `mpya` |
| RI7 | 19 | `shli`, `rotqbyi`, `bi`, `biz`, `cntb` |
| RI10 | 20 | `ai`, `andi`, `ceqi`, `mpyi`, `lqd`, `stqd` |
| RI16 | 15 | `il`, `lqa`, `br`, `brsl`, `brz` |
| RI18 | 1 | `ila` |
| Special | 3 | `nop`, `lnop`, `stop` |

---

## Getting Started

### Prerequisites

- Python 3 for the assembler.
- A SystemVerilog-capable simulator for RTL simulation, such as Questa, Xcelium, VCS, Verilator, or another simulator that supports the SystemVerilog constructs used in this project.

### Assemble the Default Program

```bash
python3 assembler.py
```

This reads `assembly.txt` and writes `instructions.txt`.

### Run a Simulation

Simulator command lines vary by tool. A typical flow is:

1. Compile the SystemVerilog source files.
2. Use `top_level_tb.sv` as the top-level testbench.
3. Ensure the simulation working directory contains `instructions.txt`, because `instruction_memory.sv` loads it with `$readmemh`.
4. Run until the testbench observes the `stop` signal held high for the configured number of cycles or until the safety timeout is reached.

Example file order for simulators that require package-first compilation:

```text
packet_pkg.sv
program_counter.sv
instruction_memory.sv
register_file.sv
local_store.sv
IF_ID_reg.sv
ID_EX_reg.sv
decode.sv
even_execute.sv
odd_execute.sv
even_pipe.sv
odd_pipe.sv
execute.sv
top_level.sv
top_level_tb.sv
```

---

## Example Workflow

```bash
# 1. Edit assembly.txt with an SPU-like program.
$EDITOR assembly.txt

# 2. Assemble into the hex image consumed by instruction memory.
python3 assembler.py

# 3. Compile and run the RTL with your preferred SystemVerilog simulator.
# Example only; adapt flags and source ordering to your simulator.
<simulator> packet_pkg.sv program_counter.sv instruction_memory.sv register_file.sv \
  local_store.sv IF_ID_reg.sv ID_EX_reg.sv decode.sv even_execute.sv \
  odd_execute.sv even_pipe.sv odd_pipe.sv execute.sv top_level.sv top_level_tb.sv
```

---

## Design Highlights for Reviewers

### Hardware architecture

- Decomposed top-level pipeline with clear fetch, decode, issue, execute, and writeback responsibilities.
- Separate even/odd execution units inspired by the Cell SPU pipeline model.
- Latency-aware instruction packets for deep-pipeline scheduling.
- Explicit register dependency checks before issue.
- Pipeline forwarding to reduce unnecessary stalls.

### RTL implementation

- Uses SystemVerilog packed structs to keep packetized pipeline state readable.
- Maintains separate packet types for decoded inputs and in-flight even/odd pipe results.
- Encapsulates memories, pipeline registers, register file, program counter, decode, and execute into reusable modules.
- Models 128-bit data paths throughout the architectural register file and execution interface.

### Tooling and verification

- Includes a custom assembler rather than relying on handwritten machine code.
- Provides both full-system and pipeline-level testbenches.
- Uses a stop-signal-based simulation termination strategy with a cycle timeout to avoid runaway simulations.
- Includes sample assembly and expected-output notes for manual and automated inspection.

---

## Current Limitations and Future Improvements

This repository is an academic/portfolio RTL project rather than a production CPU core. Potential next steps include:

- Add a simulator-specific regression script or Makefile.
- Add waveform dumping for common open-source simulation flows.
- Expand self-checking assertions in the testbenches.
- Add instruction-by-instruction golden-model comparison from Python.
- Document all instruction encodings in a generated table.
- Add CI with Verilator lint and assembler tests.
- Refine local-store addressing documentation and memory-size comments.

---

## What This Demonstrates About Me

This project shows that I can take a complex architecture problem and break it into manageable, testable components. It also demonstrates the kind of engineering discipline I bring to teams: building supporting tools, documenting architecture decisions, thinking through hazards and edge cases, and making design tradeoffs explicit.

If you are evaluating me for a hardware, embedded systems, computer architecture, FPGA, or performance-oriented engineering role, this project is intended to provide a concrete example of my ability to design and reason about non-trivial systems from the ISA/tooling layer down to RTL implementation.
