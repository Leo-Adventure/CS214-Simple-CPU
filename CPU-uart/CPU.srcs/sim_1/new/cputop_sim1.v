`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/19/2022 09:19:06 PM
// Design Name: 
// Module Name: cputop_sim1
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


module cputop_sim1(

    );
    reg[23:0] sw=0;
    reg clk;
    wire[23:0] led;
    initial begin
        clk=0;
        forever begin
            #20
            clk=~clk;
        end
    end

    wire tx;
    reg rst;
    cputop cputop_m(
        .sw(sw),
        .clk_in(clk),
        .led(led),
        .rst_in(rst),
        .start_pg(1'b0),
        .rx(1'b0),
        .tx(tx)
    );
    initial begin
        #60000;
        rst=1;
        #30000;
        rst=0;
//        #30000;
//        sw[20]=1;
//        #30000;
//        sw[20]=0;
//        $stop;
    end
endmodule
