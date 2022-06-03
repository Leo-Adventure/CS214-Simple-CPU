`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/12 17:23:07
// Design Name: 
// Module Name: practice1
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


module seg7(
    input rst_n,
    input clk,
    input [31:0] data,
    input uart_start,
    input uart_done,
    output reg [7:0] segment_en,
    output reg[7:0] segment_out
    );

    reg[31:0] display;

    reg clkout;
    reg [31:0] cnt;
    reg [2:0] scan_cnt; // 第几个灯会亮
    parameter period = 30000;
    always @(posedge clk) begin
        if(rst_n)
        begin
            cnt <= 0;
            clkout <= 0;
        end
        else
        begin
            if(cnt == period)    begin
                clkout = ~clkout;
                cnt <= 0;
            end
            else
                cnt <= cnt + 1;
        end 
    end //分频器

    always @(posedge clkout) begin
            if(rst_n)
                scan_cnt <= 0;
            else begin
                if(scan_cnt == 3'b111)
                    scan_cnt <=0;
                else
                    scan_cnt <= scan_cnt + 1;
            end
    end //作为标记，决定哪个灯亮

    always @(scan_cnt) begin
        if(rst_n)
            segment_en = 8'b1111_1111;
        else
        begin
            case(scan_cnt)
                3'b111 : segment_en = 8'b0111_1111;
                3'b110 : segment_en = 8'b1011_1111;
                3'b101 : segment_en = 8'b1101_1111;
                3'b100 : segment_en = 8'b1110_1111;
                3'b011 : segment_en = 8'b1111_0111;
                3'b010 : segment_en = 8'b1111_1011;
                3'b001 : segment_en = 8'b1111_1101;
                3'b000 : segment_en = 8'b1111_1110;
            endcase
        end
    end
    
    always @(*)
    begin
        if(uart_start)
            display = 32'h8000_0000;
        else if (uart_done)
            display = 32'h8000_0001;
        else if (rst_n)
            display = 0;
        else if (data[31])
            display = data;
        else
            display = display;
    end 


    integer i;
    reg [4:0] display_number;
    integer power_of_10;
    always @(*) begin
        if(rst_n)
            display_number = 16;
        if(display[31])
        begin
            if(display == 32'h8000_0000)
            begin
                case(scan_cnt)
                    3'b010: display_number = 7;
                    3'b011: display_number = 10;
                    3'b100: display_number = 11;
                    3'b101: display_number = 12;
                    3'b110: display_number = 1;
                    default: display_number = 16;
                endcase
            end
            else if (display == 32'h8000_0001)
            begin
                case(scan_cnt)
                    3'b011: display_number = 14;
                    3'b100: display_number = 12;
                    3'b101: display_number = 0;
                    3'b110: display_number = 0;    
                    default: display_number = 16; 
                endcase
            end
            else if (display == 32'h8000_0002)
            begin
                case(scan_cnt)
                    3'b010: display_number = 0;
                    3'b011: display_number = 15;
                    3'b100: display_number = 15;
                    3'b101: display_number = 14;
                    3'b110: display_number = 13;
                    default: display_number = 16;
                endcase
            end
        end
        else
        begin
            power_of_10 = 1;
            for(i = 0; i < scan_cnt; i = i + 1) begin
                power_of_10 = power_of_10 * 10;
            end
            display_number = (data / power_of_10)%10;
        end
    end  // 计算每一个灯应该亮的数字

    always @(*) begin
        if(rst_n)
            segment_out = 8'b1111_1111;
        else
        begin
            case(display_number)
                5'b00000: segment_out = 8'b0000_0011;
                5'b00001: segment_out = 8'b1001_1111;
                5'b00010: segment_out = 8'b0010_0101;
                5'b00011: segment_out = 8'b0000_1101;
                5'b00100: segment_out = 8'b1001_1001;
                5'b00101: segment_out = 8'b0100_1001;
                5'b00110: segment_out = 8'b0100_0001;
                5'b00111: segment_out = 8'b0001_1111;

                5'b01000: segment_out = 8'b0000_0001;
                5'b01001: segment_out = 8'b0001_1001;//0-9
                
                5'b01010: segment_out = 8'b1000_0011; //U
                5'b01011: segment_out = 8'b0011_0001; //P
                5'b01100: segment_out = 8'b0001_0011; //N
                
                5'b01101: segment_out = 8'b1001_0001; //H
                5'b01110: segment_out = 8'b0110_0001; //E 
                5'b01111: segment_out = 8'b1110_0011; //L
                
                default: segment_out = 8'b1111_1111;
            endcase
        end
    end  // 

endmodule
