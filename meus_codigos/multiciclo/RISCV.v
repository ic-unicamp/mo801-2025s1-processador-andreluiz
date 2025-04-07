module RISCV;

//Sinais
reg clk, reset, save;

//Inputs do Controller
wire [2:0] func3; // 3 bits
wire [6:0] opcode, func7; // 7 bits

//Sinais do Controller
wire IRWrite, MemWrite, AdrSrc, PCWrite, RegWrite; //1 bit
wire [1:0] ResultSrc, ALUSrcB, ALUSrcA, ImmSrc; //2 bit
wire [9:0] ALUControl; 

//Inputs do ProgramCounter
reg [31:0] PCNext;

//Outputs do ProgramCounter
wire [31:0] PC;

//Inputs do Memory
wire [31:0] address;

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



Controller cont(
	.clk(clk),
	.reset(reset), 
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
	.reset(reset),
	.PCWrite(PCWrite), 
	.PCNext(multiplex_alu), 
	.PC(PC)
);

Multiplex_address Mult_adr(
	.clk(clk),
	.reset(reset),
	.PC(PC),
	.ALUResult(multiplex_alu), 
	.AdrSrc(AdrSrc), 
	.address(multiplex_adr)
);

memory Mem(
  .address(multiplex_adr),
  .data_in(RD2),
  .data_out(ReadData),
  .we(MemWrite)
);

InstructionFetch Inst_fetch(
	.clk(clk), 
	.reset(reset), 
	.IRWrite(IRWrite), 
	.PC(PC), 
	.RD(ReadData), 
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
	.reset(reset),
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
	.reset(reset), 
	.immValue(extend), 
	.immSrc(ImmSrc), 
	.immExt(ImmExt)
);

Multiplex Multiplex_instance_SrcA (
	.clk(clk),
	.reset(reset),
	.ALUSrc(ALUSrcA),
	.opt1(PC),
	.opt2(OldPC),
	.opt3(RD1),
	.result(multiplex_srcA)
);

Multiplex Multiplex_instance_SrcB (
	.clk(clk),
	.reset(reset),
	.ALUSrc(ALUSrcB),
	.opt1(RD2),
	.opt2(ImmExt),
	.opt3(32'd4),
	.result(multiplex_srcB)
);

ALU Alu(
	.clk(clk),
 	.reset(reset), 
 	.srcA(multiplex_srcA), 
 	.srcB(multiplex_srcB), 
 	.ALUControl(ALUControl), 
 	.Zero(Zero), 
 	.ALUResult(ALUResult)
);

loadRegs_ALUOut loadReg(
	.clk(clk),
	.reset(reset),
	.ALUResult(ALUResult),
	.ALUOut(ALUOut)
);

Multiplex Multiplex_instance_ALU(
	.clk(clk),
	.reset(reset),
	.ALUSrc(ResultSrc),
	.opt1(ALUOut),
	.opt2(ReadData),
	.opt3(ALUResult),
	.result(multiplex_alu)
);

integer k=0;

always begin
	#1 clk = (clk===1'b0);
	if(clk === 1'b0) begin
		k = k+1;
	end
end
// Inicia a simulação e executa até 2000 unidades de tempo após o reset
initial begin
  reset = 1'b0;
  #11 reset = 1'b1;
  $display("*** Starting simulation. ***");
  #4000 $finish;
end

// Verifica se o endereço atingiu 4092 (0xFFC) e encerra a simulação
always @(posedge clk) begin

if(k<80)begin
$monitor("PC=%d PCNext=%d OldPC=%d,ALUSrcA=%b, ALUSrcB=%b",PC,multiplex_alu,OldPC,ALUSrcA,ALUSrcB); 
//$monitor("ALUSrcA=%d, ALUSrcB=%d, ALUResul=%d, ALUOut=%d,Rd=%b, R1=%d, R2=%d",multiplex_srcA,multiplex_srcB,ALUResult,ALUOut,Rd,Rs1,Rs2);
//$monitor("RD = %h; ALUSrcA = %b; srcA = %d; srcB = %d; RegWrite = %b; ALUResult:%d", ReadData, ALUSrcA, multiplex_srcA,multiplex_srcB, RegWrite,ALUResult);
//$monitor("A1:%b, A2:%b, RD1:%d, RD2:%d,AluResult:%d, multiplexador_alu=%d",Rs1,Rs2,RD1,RD2,ALUResult,multiplex_alu);
  if (address >= 'h10) begin
    $display("Address reached 4092 (0xFFC). Stopping simulation.");
    $finish;
  end
end else begin
$finish;
end
end



/*
// Simulação inicial
initial begin
//$monitor("IRWrite = %b, MemWrite = %b, AdrSrc = %b, PCWrite = %b, RegWrite = %b; ResultSrc = %b, ALUSrcB = %b, ALUSrcA = %b, ImmSrc = %b, ALUControl = %b\nRD1 = %d, RD2 = %d, Rd = %d", IRWrite, MemWrite, AdrSrc, PCWrite, RegWrite, ResultSrc, ALUSrcB, ALUSrcA, ImmSrc, ALUControl,RD1,RD2,Rd);
//$monitor("A1:%b, A2:%b, RD1:%d, RD2:%d,AluResult:%d, multiplexador_alu=%d",Rs1,Rs2,RD1,RD2,ALUResult,multiplex_alu);
$monitor("RD = %h;srcA = %d; srcB = %d", ReadData, multiplex_srcA,multiplex_srcB);
clk = 1;
#10;
//Ciclo 1
clk = 0;
#10;
clk = 1;
#10;

//Ciclo 2
clk = 0;
#10;
clk = 1;
#10;

//Ciclo 3
clk = 0;
#10;
clk = 1;
#10;

//Ciclo 4
clk = 0;
#10;
clk = 1;
#10;

//Ciclo 5
clk = 0;
#10;
clk = 1;
#10;

//Ciclo 6
clk = 0;
#10;
clk = 1;
#10;
//Ciclo 7
clk = 0;
#10;
clk = 1;
#10;
//Ciclo 8
clk = 0;
#10;
clk = 1;
#10;
//Ciclo 9
clk = 0;
#10;
clk = 1;
#10;
end*/




endmodule

