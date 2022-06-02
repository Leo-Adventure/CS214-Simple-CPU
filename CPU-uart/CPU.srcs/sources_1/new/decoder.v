`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SUSTech
// Engineer: Leo_Adventure
// 
// Create Date: 2022/05/11 11:34:32
// Design Name: 
// Module Name: decoder
// Project Name: CPU
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
module decode32(read_data_1,read_data_2,Instruction,mem_data,ALU_result,
                 Jal,RegWrite,MemtoReg,RegDst,Sign_extend,clock,reset,opcplus4);
    
    
    input[31:0]  Instruction;               // 取指单元来的指令

    input[31:0]  mem_data;   				// 从DATA RAM or I/O port取出的数据
    input[31:0]  ALU_result;   				// 从执行单元来的运算的结果
    input        Jal;                       // 来自控制单元，说明是JAL指令 
    input        RegWrite;                  // 来自控制单元
    input        MemtoReg;                  // 来自控制单元
    input        RegDst;             
    input		 clock,reset;               // 时钟和复位
    input[31:0]  opcplus4;                  // 来自取指单元，JAL中用
    
    output[31:0] Sign_extend;               // 扩展后的32位立即数
    output[31:0] read_data_1;               // 输出的第一操作数  
    output[31:0] read_data_2;               // 输出的第二操作数 

    reg[31:0] register[0:31]; // 寄存器数组，32个寄存器，32位存储数据
    
    // 判断指令类型
    wire R_format = (Instruction[31:26] == 6'b0)?1:0;
    wire J_format = (Instruction[5:0] == 2 || Instruction[5:0] == 3)?1:0;
    wire I_format = (!R_format && !J_format)?1:0;
 
    
    wire[4:0] read_reg1 = Instruction[25:21];
    wire[4:0] read_reg2 = Instruction[20:16];
    wire[4:0] rd = Instruction[15:11];
    wire[4:0] write_reg = (Jal)?5'b11111:(RegDst)?rd:read_reg2;// 如果 RegWrite 信号是1，则 rd 作为写入的寄存器号，否则 rt 作为写入的寄存器号

    wire is_addi = (Instruction[31:26] == 6'b00_1100)?1:0;
    wire is_ori = (Instruction[31:26] == 6'b00_1101)?1:0;
    wire is_xori = (Instruction[31:26] == 6'b00_1110)?1:0;
    wire is_sltiu = (Instruction[31:26] == 6'b00_1011)?1:0;

    integer i;
    always @(posedge clock) begin
        if(reset) begin
            for(i = 0; i < 32; i=i+1)
                register[i] <= 32'b0;
        end   
/*
        if(R_format && MemtoReg && RegWrite)
            register[write_reg] <= mem_data;
        else if(I_format && RegWrite)
            register[write_reg] <= ALU_result;
        else if(Jal) begin
            register[31] <= opcplus4;
        end
*/      
        if(RegWrite && write_reg) begin
            if(Jal)
                register[write_reg] <= opcplus4;
            else if(MemtoReg)
                register[write_reg] <= mem_data;
            else
                register[write_reg] <= ALU_result;
        end


    end

    // assign Sign_extend = {{16{Instruction[15]}}, Instruction[15:0]};
    assign Sign_extend = (is_addi || is_ori || is_xori || is_sltiu)?{16'b0,Instruction[15:0]}:{{16{Instruction[15]}},Instruction[15:0]}; // 特判几种无符号扩展，之后按照符号位来进行扩展
    assign read_data_1 = register[read_reg1];
    assign read_data_2 = register[read_reg2];

endmodule