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
    // internal registers
    reg [4:0] count = 0;
    reg [15:0] Addr;
    reg [7:0] Data_in;           

    // registers for write logic [ for safer side]
    reg write_pending = 1'b0;    
    reg [14:0] write_addr;      
    reg [7:0] write_data;       
    
    // register for read logic
    reg sdio_output_reg;         
    reg sdio_output_enable;    

    // Memory 32KB
    reg [7:0] memory [0:32767];


    // Asynchronous logic for SDIO pin
    assign SDIO = (sdio_output_enable) ? sdio_output_reg : 1'bz;


    always @(posedge sclk) begin
        if (SEN) begin
	    // No operation, all are in default state
            count <= 0;
            Addr  <= 0;
            
            // Perform Write operation after SEN becomes high
            if (write_pending) begin
                memory[write_addr] <= write_data;
                write_pending <= 1'b0; 
            end
        end 
        else begin
            
	    //counter
            count <= count + 1; 
            
            // Master writes address 
            if (count <= 15) begin
                Addr[15 - count] <= SDIO;
            end

            // Master writes Data
            if (count >= 16 && count <= 23) begin
                if (Addr[15] == 0) begin 
                    Data_in[23 - count] <= SDIO;
                end
            end
        end
        
	    // After serial data transmission complete, check the 15th bit of address and determine read/write operation
            if (count == 24 && Addr[15] == 0) begin
                write_pending <= 1'b1;
                write_addr    <= Addr[14:0];
                write_data    <= Data_in;
            end

	    // Hold count after operation is completed, break by only SEN input
            else if(count > 24) begin
                count <= 25;
            end
            
    end
    
    // Read logic
    always @(negedge sclk) begin
        if (!SEN && Addr[15] && count >= 16 && count <= 23) begin
            
            // flag for SDIO, which is use for Asynchronous data transfer
            sdio_output_enable <= 1'b1;
            sdio_output_reg    <= memory[Addr[14:0]][23-count];
        end 
        else begin
            sdio_output_enable <= 1'b0;
        end
    end

endmodule
