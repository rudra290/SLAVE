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
    parameter CLK_PERIOD  = 10;      // 10ns clock period -> 100MHz
    parameter ADDR_TEST   = 15'h1233;  // Example 15-bit Address
    parameter DATA_WRITE  = 8'hCC;     // Example 8-bit Data to write

    // Testbench Signals
    reg  sclk;
    reg  SEN;
    wire SDIO; // This is the physical bidirectional wire
    reg  sdio_master_drive; // What the master wants to drive onto SDIO
    reg  is_master_writing; // Control signal for the tri-state buffer

    // Instantiate the Device Under Test (DUT)
    SLAVE dut (
        .sclk(sclk),
        .SDIO(SDIO),
        .SEN(SEN)
    );

    // Tri-state buffer model for the master's SDIO pin
    // The master only drives the SDIO line when is_master_writing is asserted.
    // Otherwise, it's in high-impedance (z) to allow the slave to drive.
    assign SDIO = (is_master_writing) ? sdio_master_drive : 1'bz;

    // Clock Generator
    always #((CLK_PERIOD)/2) sclk = ~sclk;

    // --- TASKS for SPI Operations (24-bit protocol) ---

    // Task to perform a full WRITE transaction
    // Sends a 16-bit address (MSB is R/W=0) followed by 8 bits of data.
    task spi_write(input [15:0] addr_cmd, input [7:0] data_w);
        begin
            $display("--- Starting SPI WRITE Transaction ---");
            $display("Time: %0t ns", $time);
            $display("Writing Data 0x%h to Address 0x%h", data_w, addr_cmd[14:0]);

            is_master_writing = 1'b1; // Master will be driving the bus
            
            SEN = 0; // Assert Slave Enable
            
            // 1. Send 16-bit Address Command (MSB is R/W bit)
            for (integer i = 15; i >= 0; i = i - 1) begin
                @(negedge sclk);
                sdio_master_drive = addr_cmd[i];
            end

            // 2. Send 8-bit Data (MSB first)
            for (integer i = 7; i >= 0; i = i - 1) begin
                @(negedge sclk);
                sdio_master_drive = data_w[i];
            end

            // Finish transaction
            @(negedge sclk);
            SEN = 1; // De-assert Slave Enable
            is_master_writing = 1'b0; // Master releases the bus
            $display("--- SPI WRITE Transaction Complete ---");
        end
    endtask
        reg [15:0] read_addr_cmd = {1'b1, ADDR_TEST};
        reg [7:0] read_data;
        reg [15:0] write_addr_cmd = {1'b0, ADDR_TEST};
    // Task to perform a full READ transaction
    // Sends a 16-bit address (MSB is R/W=1) and then reads 8 bits of data.
    task spi_read(input [15:0] addr_cmd, output [7:0] data_r);
        begin
            $display("--- Starting SPI READ Transaction ---");
            $display("Time: %0t ns", $time);
            $display("Reading from Address 0x%h", addr_cmd[14:0]);

            SEN = 0; // Assert Slave Enable

            // 1. Send 16-bit Address Command (MSB is R/W bit)
            is_master_writing = 1'b1; // Master drives for command/address
            for (integer i = 15; i >= 0; i = i - 1) begin
                @(negedge sclk);
                sdio_master_drive = addr_cmd[i];
            end

            // FIX: Wait for one full clock cycle to prevent a race condition.
            // This ensures the master holds the last address bit on the bus
            // long enough for the slave to sample it before the master releases the bus.
            #6;

            // 2. Switch to read mode and capture 8 bits of data
            is_master_writing = 1'b0; // Master now safely releases the bus for the slave to drive
            for (integer i = 7; i >= 0; i = i - 1) begin
                @(posedge sclk); // Sample on the rising edge
                data_r[i] = SDIO;
            end

            // Finish transaction
            @(negedge sclk);
            SEN = 1; // De-assert Slave Enable
            $display("Read Data: 0x%h", data_r);
            $display("--- SPI READ Transaction Complete ---");
        end
    endtask


    // --- Main Test Sequence ---
    initial begin
        // 1. Initialization
        sclk = 0;
        SEN  = 1; // Slave is not selected
        is_master_writing = 1'b0; // Master is not driving
        sdio_master_drive = 1'bz;
        # (CLK_PERIOD * 2);

        // 2. Perform a WRITE operation
        // Construct the 16-bit address command: {R/W bit, 15-bit Address}
        
        spi_write(write_addr_cmd, DATA_WRITE);
        
        

        # (CLK_PERIOD * 5);
 // Wait a few cycles between transactions

        // 3. Perform a READ operation from the same address

        spi_read(read_addr_cmd, read_data);
        

        # (CLK_PERIOD * 2);
       

        // 4. Verification
        $display("--------------------------------------------------");
        $display("FINAL VERIFICATION:");
        if (read_data === DATA_WRITE) begin
            $display("  [SUCCESS] Test Passed!");
            $display("  Data written (0x%h) matches data read (0x%h).", DATA_WRITE, read_data);
        end else begin
            $display("  [FAILURE] Test Failed! Data mismatch.");
            $display("  Expected to read 0x%h, but got 0x%h.", DATA_WRITE, read_data);
        end
        $display("--------------------------------------------------");

        // 5. Finish the simulation
        # (CLK_PERIOD * 5);
        $display("INFO: Simulation finished at time %0t ns.", $time);
        $finish;
    end

endmodule


