`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SUSTech
// Engineer: Leo_Adventure
// 
// Create Date: 2022/05/11 11:34:32
// Design Name: 
// Module Name: controller
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

module control32(Opcode,Function_opcode,Jr,RegDST,ALUSrc,MemtoReg,RegWrite,MemWrite,Branch,nBranch,Jmp,Jal,I_format,Sftmd,ALUOp);
    
    
    input[5:0]   Opcode;            // 来自IFetch模块的指令高6bit，instruction[31..26]
    input[5:0]   Function_opcode;  	// 来自IFetch模块的指令低6bit，用于区分r-类型中的指令，instructions[5..0]
    output       Jr;         	 // 为1表明当前指令是jr，为0表示当前指令不是jr
    output       RegDST;          // 为1表明目的寄存器是rd，否则目的寄存器是rt
    output       ALUSrc;          // 为1表明第二个操作数（ALU中的Binput）是立即数（beq，bne除外），为0时表示第二个操作数来自寄存器
    output       MemtoReg;     // 为1表明需要从存储器或I/O读数据到寄存器
    output       RegWrite;   	  //  为1表明该指令需要写寄存器
    output       MemWrite;       //  为1表明该指令需要写存储器
    output       Branch;        //  为1表明是beq指令，为0时表示不是beq指令
    output       nBranch;       //  为1表明是Bne指令，为0时表示不是bne指令
    output       Jmp;            //  为1表明是J指令，为0时表示不是J指令
    output       Jal;            //  为1表明是Jal指令，为0时表示不是Jal指令
    output       I_format;      //  为1表明该指令是除beq，bne，LW，SW之外的其他I-类型指令
    output       Sftmd;         //  为1表明是移位指令，为0表明不是移位指令
    output[1:0]  ALUOp;        //  是R-类型或I_format=1时位1（高bit位）为1, beq、bne指令则位0（低bit位）为1

    wire lw, sw, beq, bne;
    wire R_format;

    assign beq = (Opcode == 6'b00_0100)?1:0;
    assign bne = (Opcode == 6'b00_0101)?1:0;

    assign lw = (Opcode == 6'b10_0011)?1:0;
    assign sw = (Opcode == 6'b10_1011)?1:0;

    assign Jmp = (Opcode == 2)?1:0;
    assign Jal = (Opcode == 3)?1:0;
    assign Jr = (R_format && Function_opcode == 8)?1:0;

    assign R_format = (Opcode == 6'b0)?1:0;
    assign RegDST = R_format;

    assign I_format = (Opcode[5:3] == 3'b001)?1:0; // 除了 lw, sw, beq, bne 的 opcode 后三位都是 3'b001
    assign ALUSrc = (I_format || lw || sw)?1:0; // 为 1 就代表是有立即数字段
    assign MemtoReg = lw; // 为 1 代表是有数据从内存到寄存器, 只有 lw 的时候满足要求
    assign RegWrite = ((R_format || I_format || lw || Jal) && !(Jr))?1:0;
    assign MemWrite = sw;
    assign Branch = beq;
    assign nBranch = bne;

    assign ALUOp = {R_format || I_format, bne || beq}; 

    assign Sftmd = (((Function_opcode==6'b000000)||(Function_opcode==6'b000010)
            ||(Function_opcode==6'b000011)||(Function_opcode==6'b000100)
            ||(Function_opcode==6'b000110)||(Function_opcode==6'b000111))
                && R_format)? 1'b1:1'b0;
    
endmodule