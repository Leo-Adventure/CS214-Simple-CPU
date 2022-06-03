`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2022 04:04:30 PM
// Design Name: 
// Module Name: cputop
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


module cputop(
    input rst_in,
    input enter,
    input wire[23:0] sw,
    input wire clk_in,
    output wire[23:0] led,
    //uart pinpoints
    input start_pg,
    input rx,
    output tx,

    output[7:0] segment_en,
    output[7:0] segment_out
    );
    //
    wire upg_clk, upg_clk_o;
    wire upg_wen_o; //uart write enable
    wire upg_done_o; //uart rx data have done

    wire[14:0] upg_addr_o; //uart address

    wire[31:0] upg_data_o; //uart data
    wire spg_bufg;
    BUFG U1(.I(start_pg), .O(spg_bufg));
    reg upg_rst;

    always @(posedge clk_in)
    begin
        if(spg_bufg)
            upg_rst = 0;
        if(rst_in)
            upg_rst = 1;
    end

    wire rst= rst_in | !upg_rst;
   
    wire[23:0] mem_led_out;
    assign led=mem_led_out;
    wire clk;
    cpu_clk cpu_clk1(
        .clk_in1(clk_in),
        .clk_out1(clk),
        .clk_out2(upg_clk_o)
    );

    wire upg_clk_w;
    wire upg_wen_w; 
    wire upg_done_w; 

    wire[14:0] upg_adr_w; 

    wire[31:0] upg_dat_w; 
    //to dememory32

    wire enter_confirm;

    debounce debounce1(
        .clk(clk),
        .key_in(enter),
        .key_out(enter_confirm)
    );
    
    uart Uart(
        .upg_clk_i(upg_clk_o),
        .upg_rst_i(upg_rst),
        .upg_rx_i(rx),
        .upg_clk_o(upg_clk_w),
        .upg_wen_o(upg_wen_w),
        .upg_adr_o(upg_adr_w),
        .upg_dat_o(upg_dat_w),
        .upg_done_o(upg_done_w),
        .upg_tx_o(tx)
    );
    //if
    wire[31:0] Instruction,branch_base_addr,Addr_result,link_addr;
    
    //ctrl
    wire[5:0]   Opcode = Instruction[31:26];            // 来自IFetch模块的指令高6bit，instruction[31..26]
    wire[5:0]   Function_opcode = Instruction[5:0];
    wire Jr,RegDST,ALUSrc,MemtoReg,RegWrite,MemWrite,Branch,nBranch,Jmp,Jal,I_format,Sftmd;
    wire[1:0] ALUOp;
    

    
    //alu
    wire Zero;
    wire[31:0] Read_data_1,Read_data_2,Sign_extend;//in
    wire[31:0] ALU_Result;
    wire[4:0] Shamt=Instruction[10:6];
    
    //decoder
    wire [31:0]mem_data;
    
    control32 ctrl32(
        .Opcode(Opcode),//in
        .Function_opcode(Function_opcode),//in
        .Jr(Jr),
        .RegDST(RegDST),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .nBranch(nBranch),
        .Jmp(Jmp),
        .Jal(Jal),
        .I_format(I_format),
        .Sftmd(Sftmd),
        .ALUOp(ALUOp)
    );
    
    Ifetc32 if32(
        .Instruction(Instruction),
        .branch_base_addr(branch_base_addr),
        .Addr_result(Addr_result),
        .Read_data_1(Read_data_1),
        .Branch(Branch),
        .nBranch(nBranch),
        .Jmp(Jmp),
        .Jal(Jal),
        .Jr(Jr),
        .Zero(Zero),
        .clock(clk),
        .reset(rst),
        .link_addr(link_addr),
        .upg_rst_i(upg_rst),
        .upg_clk_i(upg_clk_w),
        .upg_mem_write_i(upg_wen_w & !upg_adr_w[14]),
        .upg_address_i(upg_adr_w),
        .upg_data_i(upg_dat_w),
        .upg_done_i(upg_done_w)
    );
    
    executs32 exe32(
        .Read_data_1(Read_data_1),
        .Read_data_2(Read_data_2),
        .Sign_extend(Sign_extend),
        .Function_opcode(Function_opcode),
        .Exe_opcode(Opcode),
        .ALUOp(ALUOp),
        .Shamt(Shamt),
        .Sftmd(Sftmd),
        .ALUSrc(ALUSrc),
        .I_format(I_format),
        .Jr(Jr),
        .Zero(Zero),
        .ALU_Result(ALU_Result),
        .Addr_Result(Addr_result),
        .PC_plus_4(branch_base_addr)//pc+4
    );
    
    decode32 id32(
        .Instruction(Instruction),
        .mem_data(mem_data),
        .ALU_result(ALU_Result),
        .Jal(Jal),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .RegDst(RegDST),
        .clock(clk),
        .reset(rst),
        .opcplus4(link_addr),//another pc+4
        .Sign_extend(Sign_extend),
        .read_data_1(Read_data_1),
        .read_data_2(Read_data_2)
    );
    
    wire[31:0] seg_out;
        
    dmemory32 mem32(
        .clock(clk),
        .memWrite(MemWrite),
        .address(ALU_Result),
        .writeData(Read_data_2),
        .switch_in(sw),
        .readData(mem_data),
        .led_out(mem_led_out),
        .seg_out(seg_out),
        .upg_rst_i(upg_rst),
        .upg_clk_i(upg_clk_w),
        .upg_mem_write_i(upg_wen_w & upg_adr_w[14]),
        .upg_address_i(upg_adr_w),
        .upg_write_data_i(upg_dat_w),
        .upg_done_i(upg_done_w),
        .enter(enter_confirm),//should be confirmed
        .rst(rst)
    );

    seg7 seg7(
        .clk(clk_in),
        .rst_n(rst_in),
        .data(seg_out),
        .segment_en(segment_en),
        .segment_out(segment_out),
        .uart_start(start_pg),
        .uart_done(upg_done_w)
    );

endmodule
