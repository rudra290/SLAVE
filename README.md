# Verilog SPI Slave & Interactive Protocol Explorer

This project provides a complete solution for understanding and implementing the **SPI configuration protocol** for the **Texas Instruments ADC3664**. It consists of two main components:

- ✅ **Verilog SPI Slave Module**  
- 🌐 **Interactive SPI Protocol Explorer (Web Tool)**

---

## 🚀 Interactive Protocol Explorer

The best way to understand the protocol is to **see it in action**.

> **▶️ [Launch the Interactive Explorer](https://your-github-username.github.io/your-repo-name/)**  
> *(Note: You must enable GitHub Pages from the repository settings for this to work.)*

### Features:
- Switch between **Read** and **Write** operations.
- Enter **custom addresses** and **data values**.
- Instantly visualize the **24-bit SPI communication frame**.
- See clearly which bits are driven by the **Master** vs **Slave**.

---

## 🛠️ Verilog SPI Slave Module

The core of this project is the `SLAVE.v` module.

It emulates the SPI-based register access protocol of the **ADC3664** and is ideal for **FPGA integration** or **simulation** environments.

### 📦 Features:

- ✅ **ADC3664 Protocol Compliant**  
  Implements 3-wire SPI: `sclk`, `SEN` (active-low), `SDIO` (bidirectional).
  
- 💾 **32KB Internal Memory**  
  Contains a `32767 x 8-bit` memory block for read/write operations.

- 🔒 **Safe Write Mechanism**  
  Uses a pending-write system that latches data and commits only after `SEN` goes high.

- 🔄 **Standard Clocking Scheme**  
  - **Samples data** on **rising edge** of `sclk`  
  - **Drives data** on **falling edge** of `sclk`  

---

## 🔧 How to Use

### 1. Add `SLAVE.v` to Your Project

Include it in your FPGA or simulation environment.

### 2. Instantiate the SPI Slave

```verilog
module your_project_top (
    input  wire sclk,   // SPI Clock
    inout  wire SDIO,   // Bidirectional SPI Data
    input  wire SEN     // Slave Enable (Active Low)
);

    // Instantiate the SPI Slave module
    SLAVE adc_emulator (
        .sclk(sclk),
        .SDIO(SDIO),
        .SEN(SEN)
    );

endmodule
