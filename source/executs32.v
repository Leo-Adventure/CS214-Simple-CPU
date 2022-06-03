`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/11/2022 11:25:10 AM
// Design Name: 
// Module Name: executs32
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


module executs32(Read_data_1,Read_data_2,Sign_extend,Function_opcode,Exe_opcode,ALUOp,
                 Shamt,ALUSrc,I_format,Zero,Jr,Sftmd,ALU_Result,Addr_Result,PC_plus_4
                 );
    input[31:0]  Read_data_1;		// 从译码单元的Read_data_1中来
    input[31:0]  Read_data_2;		// 从译码单元的Read_data_2中来
    input[31:0]  Sign_extend;		// 从译码单元来的扩展后的立即数
    input[5:0]   Function_opcode;  	// 取指单元来的r-类型指令功能码,r-form instructions[5:0]
    input[5:0]   Exe_opcode;  		// 取指单元来的操作码
    input[1:0]   ALUOp;             // 来自控制单元的运算指令控制编码
    input[4:0]   Shamt;             // 来自取指单元的instruction[10:6]，指定移位次数
    input  		 Sftmd;            // 来自控制单元的，表明是移位指令
    input        ALUSrc;            // 来自控制单元，表明第二个操作数是立即数（beq，bne除外）
    input        I_format;          // 来自控制单元，表明是除beq, bne, LW, SW之外的I-类型指令
    input        Jr;               // 来自控制单元，表明是JR指令
    output       Zero;              // 为1表明计算值为0 
    output reg[31:0] ALU_Result;        // 计算的数据结果
    output[31:0] Addr_Result;		// 计算的地址结果        
    input[31:0]  PC_plus_4;         // 来自取指单元的PC+4
    
    wire[31:0] AInput=Read_data_1;
    wire[31:0] BInput=(ALUSrc==0)?Read_data_2:Sign_extend;
    reg[31:0] ALU_output_mux;
    reg[31:0] Shift_Result;
    wire[2:0] ALU_ctl;
    wire[5:0] Exe_code = (I_format==0)?Function_opcode :{ 3'b000 , Exe_opcode[2:0] };
    
    assign ALU_ctl[0] = (Exe_code[0] | Exe_code[3]) & ALUOp[1];
    assign ALU_ctl[1] = ((!Exe_code[2]) | (!ALUOp[1]));
    assign ALU_ctl[2] = (Exe_code[1] & ALUOp[1]) | ALUOp[0];
    wire[2:0] Sftm = Function_opcode[2:0];
    
    assign Zero=(ALU_output_mux==32'b0)?1'b1:1'b0;
    assign Addr_Result=PC_plus_4+(Sign_extend<<2);
    
    always @* begin
        case(ALU_ctl)
            3'b000:ALU_output_mux=AInput&BInput;
            3'b001:ALU_output_mux=AInput|BInput;
            3'b010:ALU_output_mux=$signed(AInput)+$signed(BInput);
            3'b011:ALU_output_mux=AInput+BInput;
            3'b100:ALU_output_mux=AInput^BInput;
            3'b101:ALU_output_mux=~(AInput|BInput);
            3'b110:ALU_output_mux=$signed(AInput)-$signed(BInput);
            3'b111:ALU_output_mux=AInput-BInput;
            default:ALU_output_mux=32'b0;
        endcase
    end
    always @* begin
        if(Sftmd)
            case(Sftm[2:0])
                3'b000:Shift_Result = BInput << Shamt; //Sll rd,rt,shamt 00000
                3'b010:Shift_Result = BInput >> Shamt; //Srl rd,rt,shamt 00010
                3'b100:Shift_Result = BInput << AInput; //Sllv rd,rt,rs 000100
                3'b110:Shift_Result = BInput >> AInput; //Srlv rd,rt,rs 000110
                3'b011:Shift_Result = $signed(BInput)>>>Shamt; //Sra rd,rt,shamt 00011
                3'b111:Shift_Result = $signed(BInput)>>>AInput; //Srav rd,rt,rs 00111
                default:Shift_Result = BInput;
            endcase
        else
            Shift_Result=BInput;
    end
    always @* begin
        //set type operation (slt, slti, sltu, sltiu)
        if(((ALU_ctl==3'b111) && (Exe_code[3]==1))||((ALU_ctl[2:1]==2'b11) && (I_format==1)))
            ALU_Result[31:0] = ($signed(AInput)<$signed(BInput))?32'b1:32'b0;
        //lui operation
        else if((ALU_ctl==3'b101) && (I_format==1))
            ALU_Result[31:0]= {BInput[15:0],16'b0};
        //shift operation
        else if(Sftmd==1)
            ALU_Result = Shift_Result ;
        //other types of operation in ALU (arithmatic or logic calculation)
        else
            ALU_Result = ALU_output_mux[31:0];
    end
endmodule
