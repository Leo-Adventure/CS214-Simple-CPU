`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/12 11:29:35
// Design Name: 
// Module Name: ifetch
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

module Ifetc32(Instruction,branch_base_addr,Addr_result,Read_data_1,Branch,nBranch,Jmp,Jal,Jr,Zero,clock,reset,link_addr, upg_rst_i, upg_clk_i, upg_mem_write_i, upg_address_i, upg_data_i, upg_done_i);
    output[31:0] Instruction;			// 根据PC的�?�从存放指令的prgrom中取出的指令
    output[31:0] branch_base_addr;      // 对于有条件跳转类的指令�?�言，该值为(pc+4)送往ALU
    input[31:0]  Addr_result;            // 来自ALU,为ALU计算出的跳转地址
    input[31:0]  Read_data_1;           // 来自Decoder，jr指令用的地址
    input        Branch;                // 来自控制单元
    input        nBranch;               // 来自控制单元
    input        Jmp;                   // 来自控制单元
    input        Jal;                   // 来自控制单元
    input        Jr;                   // 来自控制单元
    input        Zero;                  //来自ALU，Zero�?1表示两个值相等，反之表示不相�?
    input        clock,reset;           //时钟与复�?,复位信号用于给PC赋初始�?�，复位信号高电平有�?
    output reg[31:0] link_addr;             // JAL指令专用的PC+4

    input upg_rst_i;
    input upg_clk_i;
    input upg_mem_write_i;
    input[14:0] upg_address_i;
    input[31:0] upg_data_i;
    input upg_done_i;

    reg[31:0]   PC, Next_PC;                      // PC的�??

    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);

    wire fixed_upg_write=(upg_address_i[13:0]<14'b10_0000_0000_0000)?upg_mem_write_i:0;
    
    wire[31:0] rom_out;
    assign Instruction=(rom_out==32'h0000_000c)?32'h0c00_2000:rom_out;
    prgrom prgrom(
        .clka(kickOff? clock: upg_clk_i),
        .wea(kickOff? 1'b0 : fixed_upg_write),
        .addra(kickOff? PC[15:2] : upg_address_i[13:0]),
        .dina(kickOff? 32'h0000_0000 : upg_data_i),
        .douta(rom_out)
    );

    always @(Branch or nBranch or Zero or Addr_result or Read_data_1 or Jr or Jmp or Jal or PC or Instruction) 
    begin
        if((Branch == 1 && Zero == 1) || (nBranch == 1 && Zero == 0))
            Next_PC = Addr_result;
        else if(Jr == 1)
            Next_PC = Read_data_1;
        else if(Jal == 1 || Jmp == 1)
            Next_PC = {PC[31:28], Instruction[25:0], 2'b00};
        else
            Next_PC = PC + 4;
    end

    always @( negedge clock)
    begin 
        if(reset == 1) PC <= 32'h0000_0000; 
        else PC <= Next_PC; 
    end

    always @(negedge clock)
    begin
        if ((Jmp == 1) || (Jal == 1)) 
            link_addr <= (PC + 4);
        else
            link_addr <= link_addr;
    end

    assign branch_base_addr = PC + 4;

endmodule
