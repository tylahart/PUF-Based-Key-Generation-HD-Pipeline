# PUF-Based Key Generation & Hamming Distance Pipeline (SystemVerilog)

This repository contains core modules from a **PUF-based hardware security system** implemented in **SystemVerilog**.  
The design demonstrates challenge–response generation, Hamming distance analysis, and secure key derivation using fully synthesizable RTL.

> ⚠️ This repository is intentionally **partial** and intended for portfolio/resume purposes. System-level integration files are omitted.

---

## Project Overview

The system implements a hardware pipeline for:
- Generating a **PUF response**
- Computing **Hamming distances** against reference patterns
- Mapping distances to a derived **secret key**

The design is modular and controlled through explicit enable/done handshaking.

---

## Included Modules

### PUF
- Generates a 128-bit response vector
- Uses configurable bit flips driven by random indices
- Models challenge–response behavior common in silicon PUFs

### Hamming Distance Transform
- Converts secret key bits into low/high distance thresholds
- Produces per-bit Hamming reference values

### MAP + Hamming Blocks
- Computes Hamming distance between reference patterns and generated responses
- Applies threshold logic to derive a stable secret key
- Fully parallelized using generate blocks

### Top-Level Integration (`zaap_modules`)
- Orchestrates PUF, transform, and mapping stages
- Clean modular structure with explicit enable/done signaling

---

## Verification (Testbench)

A self-checking **SystemVerilog testbench** is included to validate functionality:
- Drives staged execution of PUF, transform, and mapping modules
- Uses both fixed and randomized 128-bit reference vectors
- Verifies enable/done handshaking and pipeline sequencing
- Exercises threshold behavior and key derivation logic

---

## Key Concepts Demonstrated

- Hardware security primitives (PUF concepts)
- Parallel Hamming distance computation
- Threshold-based key derivation
- RTL verification with directed and randomized stimulus
- Modular, synthesizable SystemVerilog design

---

## Tools & Technologies

- **Language:** SystemVerilog
- **Focus:** Hardware security, RTL design & verification
- **Style:** Modular, synthesizable logic

---

## Author

**Tyla Hart**  
Computer Engineering — Digital Design & Hardware Security

---

## License

Provided for **educational and portfolio demonstration purposes only**.
