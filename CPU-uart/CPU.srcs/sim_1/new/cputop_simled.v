`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/19/2022 09:58:37 PM
// Design Name: 
// Module Name: cputop_simled
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


module cputop_simled(

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
    
    cputop cputop_m(
        .sw(sw),
        .clk_in(clk),
        .led(led)
    );
    initial begin
        #60000;
        sw[23]=1;
        #30000;
        sw[23]=0;
        #20000;
        sw[3]=1;
        #20000;
        sw[3]=0;
        $stop;
    end
endmodule
