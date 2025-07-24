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
    reg R_W,sdio_in;
    reg [4:0]count = 0;
    reg [15:0]Addr;
    reg [7:0]Data;
    always @(posedge sclk) begin
    if(SEN) begin
    count = 0;
    end
    else begin
    case(count)
    5'b00000: begin
        R_W = SDIO;
        Addr[15] = 0;
        count = 5'b00001;
        end
    5'b00001: begin
        Addr[14] = 0;
        count = 5'b00010;
        end
    5'b00010: begin
        Addr[13] = 0;
        count = 5'b00011;
        end
    5'b00011: begin
        Addr[12] = SDIO;
        count = 5'b00100;
        end
    5'b00100: begin
        Addr[11] = SDIO;
        count = 5'b00101;
        end
    5'b00101: begin
        Addr[10] = SDIO;
        count = 5'b00110;
        end
    5'b00110: begin
        Addr[9] = SDIO;
        count = 5'b00111;
        end
    5'b00111: begin
        Addr[8] = SDIO;
        count = 5'b01000;
        end
    5'b01000: begin
        Addr[7] = SDIO;
        count = 5'b01001;
        end
    5'b01001: begin
        Addr[6] = SDIO;
        count = 5'b01010;
        end
    5'b01010: begin
        Addr[5] = SDIO;
        count = 5'b01011;
        end
    5'b01011: begin
        Addr[4] = SDIO;
        count = 5'b01100;
        end
    5'b01100: begin
        Addr[3] = SDIO;
        count = 5'b01101;
        end
    5'b01101: begin
        Addr[2] = SDIO;
        count = 5'b01110;
        end
    5'b01110: begin
        Addr[1] = SDIO;
        count = 5'b01111;
        end
    5'b01111: begin
        Addr[0] = SDIO;
        count = 5'b10000;
        end
    5'b10000: begin
        Data[7] = SDIO;
        count = 5'b10001;
        end
    5'b10001: begin
        Data[6] = SDIO;
        count = 5'b10010;
        end
    5'b10010: begin
        Data[5] = SDIO;
        count = 5'b10011;
        end
    5'b10011: begin
        Data[4] = SDIO;
        count = 5'b10100;
        end
    5'b10100: begin
        Data[3] = SDIO;
        count = 5'b10101;
        end
    5'b10101: begin
        Data[2] = SDIO;
        count = 5'b10110;
        end
    5'b10110: begin
        Data[1] = SDIO;
        count = 5'b10111;
        end
    5'b10111: begin
        Data[0] = SDIO;
        count = 5'b11000;
        end
    default: begin
        count = 5'b11000;  
        end
    endcase
    end
    end
    
endmodule
