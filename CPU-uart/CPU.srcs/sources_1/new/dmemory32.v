`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/14 15:33:14
// Design Name: 
// Module Name: dmemory32
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

module dmemory32(
        inout clock,
        input rst,
        input memWrite,
        input [31:0] address,
        input [31:0] writeData,
        output reg [31:0] readData,
        input [23:0]switch_in,
        output reg [23:0] led_out, 
        output reg [31:0] seg_out,
        input upg_rst_i,
        input upg_clk_i,
        input upg_mem_write_i,
        input [14:0] upg_address_i,
        input [31:0] upg_write_data_i,
        input upg_done_i,
        input enter
    );
    
    reg[31:0] read_from_switch;
   
    wire fixed_write=(address[31] ==1'b1)?0:memWrite;
    wire[31:0] read_from_ram;
    wire clk = !clock;

    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);
    
    always @(*)
    begin
         read_from_switch = {8'b0000_0000, switch_in};
    end
   
    
    RAM ram(
        .clka(kickOff? clk : upg_clk_i),
        .wea(kickOff? fixed_write : upg_mem_write_i),
        .dina(kickOff? writeData : upg_write_data_i),
        .douta(read_from_ram),
        .addra(kickOff? address[15:2] : upg_address_i[13:0])
    );
    
    always @(*)//read
    begin
        if(address[31:30] == 2'b10)
            readData = read_from_switch;
        else if(address[31:30] == 2'b11)
            readData = enter;
        else
            readData=read_from_ram;
    end
    
    always @(negedge clock)
    begin
        if(rst)
            led_out<=0;
        else if(address[31:30] ==2'b10 && memWrite)
            led_out<=writeData[23:0];
        else
            led_out<=led_out;
    end

    always @(negedge clock)
    begin
        if(rst)
            seg_out=0;
        else if(address[31:30] ==2'b11 && memWrite)
            seg_out=writeData;
        else if(address[31:30] ==2'b10 && memWrite)
            seg_out={8'b0000_0000, writeData[23:0]};
        else
            seg_out = seg_out;
    end

endmodule