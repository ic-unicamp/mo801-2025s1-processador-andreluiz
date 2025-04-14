module core( // modulo de um core
  input clk, // clock
  input resetn, // reset que ativa em zero
  output [31:0] address, // endereço de saída
  output [31:0] data_out, // dado de saída
  input [31:0] data_in, // dado de entrada
  output we // write enable
);

//Inputs do Controller
wire [2:0] func3; // 3 bits
wire [6:0] opcode, func7; // 7 bits

//Sinais do Controller
wire IRWrite, MemWrite, AdrSrc, PCWrite, RegWrite; //1 bit
wire [1:0] ResultSrc, ALUSrcB, ALUSrcA; //2 bit
wire [2:0] ImmSrc;
wire [9:0] ALUControl; 

//Inputs do ProgramCounter
reg [31:0] PCNext;

//Outputs do ProgramCounter
wire [31:0] PC;

//Outputs do Memory
wire [31:0] ReadData; //Também é input do fetch data

//Outputs do FetchData (além dos já declarados func3, func7 e opcode)
wire [4:0] Rs1, Rs2, Rd; //Também é input do register file
wire [24:0] extend; //Também é input do extend
wire [31:0] OldPC;

//Outputs do RegisterFile
wire [31:0] RD1, RD2; //O RD2 também é Input do memory, fazendo o papel de Write Data

//Outputs do Extend
wire [31:0] ImmExt;

//Output da ALU
wire Zero;
wire [31:0] ALUResult, ALUOut;

//Output dos multiplexadores
//Multiplexador ALU - ALUResult(00), ReadData(01), ALUOut(10)
wire [31:0] multiplex_alu;

//Multiplexador SrcA - PC(00), OldPC(01), RD1(10)
wire [31:0] multiplex_srcA;

//Multiplexador SrcB - RD2(00), ImmExt(01), 4(10)
wire [31:0] multiplex_srcB;

//Multiplexador Adr - PC(0), address(1)
wire [31:0] multiplex_adr;

//ReadData == data_in

Controller cont(
	.clk(clk),
	.reset(resetn), 
	.opcode(opcode), 
	.func3(func3), 
	.func7(func7), 
	.Zero(Zero), 
	.IRWrite(IRWrite), 
	.MemWrite(MemWrite), 
	.AdrSrc(AdrSrc), 
	.PCWrite(PCWrite), 
	.RegWrite(RegWrite), 
	.ResultSrc(ResultSrc), 
	.ALUSrcB(ALUSrcB), 
	.ALUSrcA(ALUSrcA), 
	.ImmSrc(ImmSrc), 
	.ALUControl(ALUControl)
);

ProgramCounter Prog_count(
	.clk(clk), 
	.reset(resetn),
	.PCWrite(PCWrite), 
	.PCNext(multiplex_alu), 
	.PC(PC)
);

Multiplex_address Mult_adr(
	.clk(clk),
	.reset(resetn),
	.PC(PC),
	.ALUResult(multiplex_alu), 
	.AdrSrc(AdrSrc), 
	.address(multiplex_adr)
);

InstructionFetch Inst_fetch(
	.clk(clk), 
	.reset(resetn), 
	.IRWrite(IRWrite), 
	.PC(PC), 
	.RD(data_in), 
	.OldPC(OldPC), 
	.Instruction_rs1(Rs1), 
	.Instruction_rs2(Rs2), 
	.Instruction_rd(Rd), 
	.Instruction_extend(extend), 
	.Instruction_op(opcode), 
	.Instruction_func3(func3), 
	.Instruction_func7(func7)
);

RegisterFile Reg_file(
	.clk(clk),
	.reset(resetn),
	.A1(Rs1),
	.A2(Rs2),
	.A3(Rd),
	.WD3(multiplex_alu),
	.WE3(RegWrite),
	.RD1(RD1),
	.RD2(RD2)
);

Extend Ext(
	.clk(clk),
	.reset(resetn), 
	.immValue(extend), 
	.immSrc(ImmSrc), 
	.immExt(ImmExt)
);

Multiplex Multiplex_instance_SrcA (
	.clk(clk),
	.reset(resetn),
	.ALUSrc(ALUSrcA),
	.opt1(PC),
	.opt2(OldPC),
	.opt3(RD1),
	.result(multiplex_srcA)
);

Multiplex Multiplex_instance_SrcB (
	.clk(clk),
	.reset(resetn),
	.ALUSrc(ALUSrcB),
	.opt1(RD2),
	.opt2(ImmExt),
	.opt3(32'd4),
	.result(multiplex_srcB)
);

ALU Alu(
	.clk(clk),
 	.reset(resetn), 
 	.srcA(multiplex_srcA), 
 	.srcB(multiplex_srcB), 
 	.ALUControl(ALUControl), 
 	.Zero(Zero), 
 	.ALUResult(ALUResult)
);

loadRegs_ALUOut loadReg(
	.clk(clk),
	.reset(resetn),
	.ALUResult(ALUResult),
	.ALUOut(ALUOut)
);

Multiplex Multiplex_instance_ALU(
	.clk(clk),
	.reset(resetn),
	.ALUSrc(ResultSrc),
	.opt1(ALUOut),
	.opt2(data_in),
	.opt3(ALUResult),
	.result(multiplex_alu)
);

assign data_out = RD2;
assign address = multiplex_adr;
assign we = MemWrite;

/*always @(posedge clk) begin
  if (resetn == 1'b0) begin
    address <= 32'h00000000;
  end else begin
    address <= address + 4;
  end
  we = 0;
  data_out = 32'h00000000;
end*/

endmodule
