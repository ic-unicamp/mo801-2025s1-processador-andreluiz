module InstructionFetch(clk, reset, IRWrite, PC, RD, OldPC, Instruction_rs1, Instruction_rs2, Instruction_rd, Instruction_extend, Instruction_op, Instruction_func3, Instruction_func7);
input clk, reset, IRWrite;
input [31:0] PC, RD;
output reg [31:0] OldPC;
output reg [4:0]Instruction_rs1, Instruction_rs2, Instruction_rd;
output reg [24:0] Instruction_extend;
output reg [6:0]Instruction_op;
output reg [2:0] Instruction_func3;
output reg [6:0] Instruction_func7;

reg [31:0] InstructionRegister;

always @ (posedge clk)
begin
	if(IRWrite == 1) begin
	   InstructionRegister = RD;
	   $display("InstructionRegister = %b", InstructionRegister);
	end	

        Instruction_op = RD[6:0];
        Instruction_rd = RD[11:7];
	Instruction_rs1 = RD[19:15];
	Instruction_rs2 = RD[24:20];
	Instruction_extend = RD[31:7];
	Instruction_func3 = RD[14:12];
	Instruction_func7 = RD[31:25];
        OldPC = PC;
end
endmodule
