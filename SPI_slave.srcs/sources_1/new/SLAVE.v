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
    
    // Internal memory for the slave
    reg [7:0] memory [0:65535];
    
    // This is the output driver for the SDIO pin
    // It's active only during a read operation when SEN is low.
    assign SDIO = (!SEN && Addr[15] && count > 16) ? Data_out[7] : 1'bz;

    // Main logic block
    always @(posedge sclk) begin
        if (SEN) begin
            // When Slave Enable is high, reset everything
            count <= 0;
            Addr  <= 0;
        end 
        else begin
            // When Slave Enable is low, the transaction is active
            count <= count + 1; // Increment count on each clock edge
            
            // State 0: Capture the Read/Write command bit
            if (count == 0) begin
                Addr[15] <= SDIO;
            end
            
            // States 1-16: Capture the 16-bit address
            // This is done serially, bit by bit
            if (count >= 1 && count <= 16) begin
                Addr[15 - count] <= SDIO;
            end

            // States 17-24: Data phase
            if (count >= 17 && count <= 23) begin
                if (Addr[15] == 0) begin // It's a WRITE operation
                    // Capture the data bits coming from the master
                    Data_in[24 - count] <= SDIO;
                end
                else begin // It's a READ operation
                    // Shift out the data from Data_out register
                    Data_out <= {Data_out[6:0], 1'b0}; 
                end
            end

            // End of transaction processing
            if (count == 16 && Addr[15] == 1) begin
                // If it's a READ, load the data from memory after address is received
                Data_out <= memory[Addr];
            end

            if (count == 23 && Addr[15] == 0) begin
                // If it's a WRITE, store the received data into memory
                memory[Addr] <= Data_in;
            end
        end
    end

endmodule
