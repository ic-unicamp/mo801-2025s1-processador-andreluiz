module RISCV;

// Sinais
reg clk, reset, IRWrite;
reg[1:0] immSrc;
reg [31:0] PC, RD;
wire [31:0] OldPC;

reg [31:0] WD3;
reg WE3;

//Fios entre o InstructionFetch e o RegFile/Extend
wire [4:0] Instruction_rs1, Instruction_rs2, Instruction_rd;
wire [24:0] Instruction_extend;
wire [6:0] Instruction_op;
wire [2:0] Instruction_func3;
wire [6:0] Instruction_func7;

//Fios de saída do RegFile
wire [31:0] RD1, RD2;

//Fios de saída do Extend
wire [11:0] immExt_l;

//Fios que saem da ALU
wire [31:0] ALUResult;

InstructionFetch inst_fetch(
	.clk(clk), 
	.reset(reset), 
	.IRWrite(IRWrite), 
	.PC(PC), 
	.RD(RD), 
	.OldPC(OldPC), 
	.Instruction_rs1(Instruction_rs1), 
	.Instruction_rs2(Instruction_rs2), 
	.Instruction_rd(Instruction_rd), 
	.Instruction_extend(Instruction_extend), 
	.Instruction_op(Instruction_op), 
	.Instruction_func3(Instruction_func3), 
	.Instruction_func7(Instruction_func7)
);

RegisterFile reg_file(
	.clk(clk),
	.reset(reset),
	.A1(Instruction_rs1),
	.A2(Instruction_rs2),
	.A3(Instruction_rd),
	.WD3(WD3),
	.WE3(WE3),
	.RD1(RD1),
	.RD2(RD2)
);

Extend extend(
	.clk(clk),
	.reset(reset), 
	.immValue(Instruction_extend), 
	.immSrc(immSrc), 
	.immExt_l(immExt_l)
);

ALU alu(
	.clk(clk),
 	.reset(reset), 
 	.srcA(RD1), 
 	.srcB(immExt_l), 
 	.ALUControl(2'b10), 
 	.Zero(0), 
 	.ALUResult(ALUResult)
);

// Gerador de clock
initial begin
clk = 0;
#10;
end

// Simulação inicial
initial begin
     clk = 1;
     reset = 1;
     PC = 1'd1;
     RD = 32'b00000000010000010010000100000011;
     #10;	 
     clk = 2;     
     reset = 0;
     #10;
     clk = 3;
     immSrc = 2'b00;
     #10;
     clk = 4;
     immSrc = 2'b00;

    $display("RD=%b",RD);
    $display("Instruction_rs1 = %b, Instruction_rs2= %b, Instruction_rd= %b, Instruction_extend= %b, Instruction_op= %b, Instruction_func3= %b, Instruction_func7= %b", Instruction_rs1, Instruction_rs2, Instruction_rd, Instruction_extend, Instruction_op, Instruction_func3, Instruction_func7);
    $display("RD1 = %b, RD2= %b", RD1, RD2);
    $display("immExt_l= %b", immExt_l);
    $display("ALUResult = %d",ALUResult);
end


endmodule

