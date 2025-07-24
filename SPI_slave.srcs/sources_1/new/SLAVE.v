`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.07.2025 23:37:31
// Design Name: 
// Module Name: SLAVE
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


module SLAVE(
    input sclk,
    inout SDIO,
    input SEN
);

    // Internal registers
    reg [4:0] count = 0;
    reg [15:0] Addr;
    reg [7:0] Data_in;           // Data received from master
    
    // Registers to hold data for a pending write operation
    reg write_pending = 1'b0;    // Flag to indicate a write is ready
    reg [14:0] write_addr;       // Latched address for the write
    reg [7:0] write_data;        // Latched data for the write
    
    // NEW: Registers to control the output driver on the negative clock edge
    reg sdio_output_reg;         // Holds the single bit to be driven by the slave
    reg sdio_output_enable;      // Controls the tri-state buffer for the SDIO pin

    // Internal memory for the slave
    reg [7:0] memory [0:32767];
    
    // This is the output driver for the SDIO pin.
    // It is now controlled by dedicated registers updated on the negedge.
    assign SDIO = (sdio_output_enable) ? sdio_output_reg : 1'bz;

    // Main state machine and data capture logic (on posedge)
    always @(posedge sclk) begin
        if (SEN) begin
            // When SEN is high, the transaction is inactive.
            count <= 0;
            Addr  <= 0;
            
            // If a write was pending from the completed transaction, execute it now.
            if (write_pending) begin
                memory[write_addr] <= write_data;
                write_pending <= 1'b0; // Clear the flag after the write is done
            end
        end 
        else begin
            // When SEN is low, the transaction is active.
            count <= count + 1; // Increment count on each clock edge
            
            // States 0-15: Capture the 16-bit address command
            if (count <= 15) begin
                Addr[15 - count] <= SDIO;
            end

            // States 16-23: Capture data during a WRITE operation
            if (count >= 16 && count <= 23) begin
                if (Addr[15] == 0) begin 
                    Data_in[23 - count] <= SDIO;
                end
            end
        end
        // At the end of a WRITE cycle, latch the data for the pending write.
            if (count == 24 && Addr[15] == 0) begin
                write_pending <= 1'b1;
                write_addr    <= Addr[14:0];
                write_data    <= Data_in;
            end
            else if(count > 24) begin
                count <= 25;
            end
            
    end
    
    // NEW: Output driver logic (on negedge)
    // This block ensures the slave changes its output on the falling edge,
    // giving the master a stable signal to read on the next rising edge.
    always @(negedge sclk) begin
        if (!SEN && Addr[15] && count >= 16 && count <= 23) begin
            // During the data phase of a read, enable the output driver
            // and place the correct bit from Data_out onto the output register.
            sdio_output_enable <= 1'b1;
            sdio_output_reg    <= memory[Addr[14:0]][23-count];
        end 
        else begin
            // At all other times, disable the output driver.
            sdio_output_enable <= 1'b0;
        end
    end

endmodule
