module RISCV;

//Sinais
reg clk, reset, save;

//Inputs do Controller
wire [2:0] func3; // 3 bits
wire [6:0] opcode, func7; // 7 bits

//Sinais do Controller
reg IRWrite, MemWrite, AdrSrc, PCWrite, RegWrite; //1 bit
reg [1:0] ResultSrc, ALUSrcB, ALUSrcA, ImmSrc; //2 bit
reg [2:0] ALUControl; 

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

reg [31:0] teste = 32'b00101010010110; 

ProgramCounter Prog_count(
	.clk(clk), 
	.reset(reset),
	.PCWrite(PCWrite), 
	.PCNext(teste), 
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
 	.Zero(0), 
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
	.opt1(ALUResult),
	.opt2(ReadData),
	.opt3(ALUOut),
	.result(multiplex_alu)
);


// Gerador de clock
initial begin
clk = 0;
reset = 0;
IRWrite = 0; 
MemWrite = 0; 
AdrSrc = 0; 
PCWrite = 1; 
RegWrite = 0;
ResultSrc = 0;
ALUSrcB = 0; 
ALUSrcA = 0;
ImmSrc = 0; 
ALUControl = 0;
#10;
end

// Simulação inicial
initial begin
$monitor("PCNext=%d, PC=%b, address=%b, ReadData=%b\nRs1=%b,Rs2=%b,Rd=%b,extend=%b,opcode=%b,func3=%b,func7=%b\n ImmSrc=%b, ImmExt = %d, Rs1=%d, RD1=%d\n ALUSrcA = %b, ALUSrcB = %b , ALUControl = %b\n ALUResult = %d, ALUOut = %d\n Multiplexador da ALU = %d",teste,PC,multiplex_adr,ReadData,Rs1,Rs2,Rd,extend,opcode,func3,func7, ImmSrc, ImmExt,Rs1, RD1, ALUSrcA, ALUSrcB, ALUControl, ALUResult, ALUOut, multiplex_alu);
//Fetch
clk=1;
#10;
clk=0;
#10;
clk=1;
#10;
clk=0;
#10;
clk=1;
#10;
clk=0;
#10;
//Decode and find RD1
ImmSrc = 2'b00;
//find extend 
clk=1;
#10;
clk=0;
#10;
//Define valores que irão para a ALU e qual operação será feita
ALUSrcA = 2'b10;
ALUSrcB = 2'b01;
ALUControl = 2'b10;
clk=1;
#10;
clk=0;
#10;
//Salva valor no ALUOut
clk=1;
#10;
clk=0;

//Pega o valor no memory e salva no banco
AdrSrc = 1;
#10;
clk=1;
#10;
clk=0;
#10;
ResultSrc = 2'b01;
clk=1;
#10;
clk=0;  
#10;
RegWrite = 1;
clk=1;
#10;
clk=0;
#10;
end




endmodule

