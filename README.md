# Verilog SPI Slave – ADC3664 Emulator

This repository contains a Verilog implementation of an SPI (Serial Peripheral Interface) Slave designed to emulate the register access protocol of the **Texas Instruments ADC3664** or similar SPI-compatible ADCs. This module captures address and data bits from an SPI master, supports both read and write operations, and interfaces through a bidirectional `SDIO` line.

---

## 🛠️ Features

- SPI Slave protocol handling with:
  - 16-bit address phase
  - 8-bit data phase
- Supports **read** and **write** operations
- Tri-state bidirectional `SDIO` line
- Internal memory (`32 KB`) for register emulation
- Edge-sensitive logic (rising edge for capture, falling edge for output drive)

---
