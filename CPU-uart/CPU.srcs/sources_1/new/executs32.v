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
    input[31:0]  Read_data_1;		// �����뵥Ԫ��Read_data_1����
    input[31:0]  Read_data_2;		// �����뵥Ԫ��Read_data_2����
    input[31:0]  Sign_extend;		// �����뵥Ԫ������չ���������
    input[5:0]   Function_opcode;  	// ȡָ��Ԫ����r-����ָ�����,r-form instructions[5:0]
    input[5:0]   Exe_opcode;  		// ȡָ��Ԫ���Ĳ�����
    input[1:0]   ALUOp;             // ���Կ��Ƶ�Ԫ������ָ����Ʊ���
    input[4:0]   Shamt;             // ����ȡָ��Ԫ��instruction[10:6]��ָ����λ����
    input  		 Sftmd;            // ���Կ��Ƶ�Ԫ�ģ���������λָ��
    input        ALUSrc;            // ���Կ��Ƶ�Ԫ�������ڶ�������������������beq��bne���⣩
    input        I_format;          // ���Կ��Ƶ�Ԫ�������ǳ�beq, bne, LW, SW֮���I-����ָ��
    input        Jr;               // ���Կ��Ƶ�Ԫ��������JRָ��
    output       Zero;              // Ϊ1��������ֵΪ0 
    output reg[31:0] ALU_Result;        // ��������ݽ��
    output[31:0] Addr_Result;		// ����ĵ�ַ���        
    input[31:0]  PC_plus_4;         // ����ȡָ��Ԫ��PC+4
    
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
