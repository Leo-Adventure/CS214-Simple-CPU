`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/12 00:40:47
// Design Name: 
// Module Name: confirmModule
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

module debounce(
input wire clk,
input wire key_in,
output reg key_out
);
// 20ms parameter
parameter TIME_20MS = 300000;
// variable
reg [20:0] cnt;
reg key_cnt;
// debounce time passed, refresh key state
always @(posedge clk) begin
if(cnt == TIME_20MS - 1)
key_out <= key_in;
end
// while in debounce state, count, otherwise 0
always @(posedge clk) begin
if(key_cnt)
cnt <= cnt + 1'b1;
else
cnt <= 0;
end
//
always @(posedge clk) begin
if(key_cnt == 0 && key_in != key_out)
key_cnt <= 1;
else if(cnt == TIME_20MS - 1)
key_cnt <= 0;
end
endmodule
