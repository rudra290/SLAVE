`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.07.2025 00:36:41
// Design Name: 
// Module Name: SLAVE_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SLAVE_tb();
 // Test Parameters
    parameter CLK_PERIOD = 10;          // 10ns clock period -> 100MHz
    parameter ADDR_TEST  = 12'hF0A;     // Example Address to write
    parameter DATA_TEST  = 8'h5C;       // Example Data to write

    // Testbench Signals (Master's perspective)
    reg  sclk;
    reg  SEN;
    reg  sdio_master_out; // Data driven by the master
    wire SDIO;            // Bidirectional data line
    reg [23:0]spi_frame;
    // Instantiate the Device Under Test (DUT)
    SLAVE dut (
        .sclk(sclk),
        .SDIO(SDIO),
        .SEN(SEN)
    );

    // The master drives the SDIO line when SEN is low (active) for a write operation.
    // When SEN is high, the line is high-impedance.
    assign SDIO = (SEN == 1'b0) ? sdio_master_out : 1'bz;

    // Clock Generator
    always #((CLK_PERIOD)/2) sclk = ~sclk;

    // Main Test Sequence
    initial begin
        // 1. Initialization
        $display("--------------------------------------------------");
        $display("INFO: Starting Testbench for SLAVE write cycle at time %0t.", $time);
        sclk = 0;
        SEN  = 1; // Slave is not selected initially
        sdio_master_out = 1'bz; // Master is not driving the line
        # (CLK_PERIOD * 2);

        // 2. Prepare the 24-bit data frame for the write operation
        // Frame Format: {R/W bit, 3 reserved bits, 12-bit Address, 8-bit Data}

        spi_frame = {1'b0, 3'b000, ADDR_TEST, DATA_TEST}; // R/W=0 for Write

        $display("INFO: Preparing SPI frame for writing...");
        $display("  -> Address = 0x%h", ADDR_TEST);
        $display("  -> Data    = 0x%h", DATA_TEST);
        $display("  -> Full Frame = 0x%h", spi_frame);
        $display("--------------------------------------------------");

        // 3. Start SPI Transaction
        SEN = 0; // Assert Slave Enable (active low)
        $display("INFO: SEN asserted low at time %0t. Starting transaction.", $time);

        // 4. Send the 24 bits, MSB first.
        // Data is changed on the falling edge of sclk, and the slave samples on the rising edge.
        for (integer i = 23; i >= 0; i = i - 1) begin
            @(negedge sclk);
            sdio_master_out = spi_frame[i];
        end

        // Wait for the last bit to be clocked into the slave
        @(negedge sclk);
        sdio_master_out = 1'bz; // Master releases the line

        // 5. End SPI Transaction
        SEN = 1; // De-assert Slave Enable
        $display("INFO: SEN de-asserted high at time %0t. Transaction ended.", $time);
        
        # (CLK_PERIOD); // Allow some time before checking registers

        // 6. Verification
        $display("--------------------------------------------------");
        $display("VERIFICATION:");

        // Check if the received data matches the sent data
        if (dut.R_W === 1'b0 && dut.Addr[11:0] === ADDR_TEST && dut.Data === DATA_TEST) begin
            $display("  [SUCCESS] Test Passed! Slave received the correct data.");
            $display("      -> R/W: %b", dut.R_W);
            $display("      -> Addr: 0x%h", dut.Addr[11:0]);
            $display("      -> Data: 0x%h", dut.Data);
        end else begin
            $display("  [FAILURE] Test Failed! Data mismatch.");
            $display("      -> Expected R/W: 0, Got: %b", dut.R_W);
            $display("      -> Expected Addr: 0x%h, Got: 0x%h", ADDR_TEST, dut.Addr[11:0]);
            $display("      -> Expected Data: 0x%h, Got: 0x%h", DATA_TEST, dut.Data);
        end
        $display("--------------------------------------------------");


        // 7. Finish the simulation
        # (CLK_PERIOD * 5);
        $display("INFO: Simulation finished at time %0t.", $time);
        $finish;
    end

endmodule