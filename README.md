# 🧪 SPI Protocol Explorer – ADC3664 Emulator

A fully interactive web-based visualization tool to explore the **SPI protocol** used by the **TI ADC3664 ADC**. This emulator demonstrates how to build and understand 24-bit SPI transactions used in real-world embedded systems.

> 🔧 Built for hardware engineers, students, and hobbyists working with SPI-based communication and register-level interactions.

---

## 🔗 Live Demo

👉 [View Online Demo](#) *(insert your deployment link here, e.g., GitHub Pages, Netlify)*

---

## 🧰 Features

- 🎛️ **Interactive SPI Frame Generator**  
  Build custom SPI transactions by selecting **Read/Write**, entering a **15-bit address**, and **8-bit data** (for write). Instantly visualize the frame bit-by-bit.

- 🎨 **Real-Time Visualization**  
  View SPI frame as a series of color-coded bits driven by **master** or **slave**. Blue = master, Green = slave.

- 💾 **ADC3664 Protocol Accurate**  
  3-wire SPI compliant: `sclk`, `SEN`, `SDIO`, mimicking the **TI ADC3664** configuration protocol.

- 🧠 **32KB Internal Memory Map Emulation**  
  Simulates `32767 x 8-bit` memory block used for register reads/writes.

- ⌛ **Pending Write System**  
  Emulates real device behavior by applying writes only after `SEN` goes high.

- 📋 **Verilog Code Copy Tool**  
  Includes instantiation code block with one-click copy button for fast use in RTL designs.

---

## ⚙️ SPI Frame Format


- **Write**: Master sends all 24 bits  
- **Read**: Master sends first 16 bits, slave responds with 8-bit data

| Signal | Role |
|--------|------|
| `sclk` | Clock input |
| `SEN`  | Slave Enable (active low) |
| `SDIO` | Bidirectional data line |

---

## 📷 Screenshot

> *A dynamic SPI frame generator with bit visualization*

![screenshot](assets/screenshot.png) <!-- Add a screenshot in your repo or remove this line -->

---

## 🖥️ Usage

1. Open the web app.
2. Select **Read** or **Write**.
3. Enter:
   - A **15-bit hexadecimal address** (e.g. `1A3F`)
   - (For Write) an **8-bit data value** (e.g. `D5`)
4. Click **"Generate Frame"** to see the full bit stream.

Color Legend:
- 🟦 **Master-driven bits**
- 🟩 **Slave-driven bits**

---

## 🔩 Example Verilog Instantiation

```verilog
// Example instantiation in a top-level module

module your_project_top (
    // Your other ports...
    input  wire sclk,  // SPI Clock
    inout  wire SDIO,  // Bidirectional SPI Data
    input  wire SEN    // Slave Enable (Active Low)
);

    // Instantiate the SPI Slave module
    SLAVE adc_emulator (
        .sclk(sclk),
        .SDIO(SDIO),
        .SEN(SEN)
    );

endmodule
```
🧑‍💻 Author

Made with ❤️ by rudra290

Based on the SLAVE.v implementation for ADC register emulation.
