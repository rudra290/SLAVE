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
    reg [7:0] Data_out;          // Data to be sent to master
    
    // NEW: Registers to hold data for a pending write operation
    reg write_pending = 1'b0;    // Flag to indicate a write is ready
    reg [14:0] write_addr;       // Latched address for the write
    reg [7:0] write_data;        // Latched data for the write
    
    // Internal memory for the slave
    reg [7:0] memory [0:32767];
    
    // This is the output driver for the SDIO pin
    // It's active only during a read operation (Addr[15]==1) when SEN is low.
    assign SDIO = (!SEN && Addr[15] && count >= 16) ? Data_out[7] : 1'bz;

    // Main logic block
    always @(posedge sclk) begin
        if (SEN) begin
            // When SEN is high, the transaction is inactive.
            // Reset the transaction state machine.
            count <= 0;
            Addr  <= 0;
            
            // NEW: If a write was pending from the completed transaction, execute it now.
            if (write_pending) begin
                memory[write_addr] <= write_data;
                write_pending <= 1'b0; // Clear the flag after the write is done
            end
        end 
        else begin
            // When SEN is low, the transaction is active.
            count <= count + 1; // Increment count on each clock edge
            
            // States 0-15: Capture the 16-bit address command
            // MSB (Addr[15]) is the R/W bit.
            if (count <= 15) begin
                Addr[15 - count] <= SDIO;
            end

            // States 16-23: Data phase
            if (count >= 16 && count <= 23) begin
                if (Addr[15] == 0) begin // It's a WRITE operation
                    // Capture the data bits coming from the master
                    Data_in[23 - count] <= SDIO;
                end
                else begin // It's a READ operation
                    // Shift out the data from Data_out register
                    Data_out <= {Data_out[6:0], 1'b0}; 
                end
            end
         
        end
        
        // NEW: At the end of the data phase of a WRITE cycle, latch the data
        // and set the pending flag instead of writing directly to memory.
            
        if (count == 24 && Addr[15] == 0) begin
                write_pending <= 1'b1;
                write_addr    <= Addr[14:0];
                write_data    <= Data_in;
        end
        
        // After address is fully received in a READ cycle, load data for sending
        if (count == 16 && Addr[15] == 1) begin
                // If it's a READ, load the data from memory after address is received
             Data_out <= memory[Addr[14:0]]; // Use only the 15-bit address part
        end
    end

endmodule

