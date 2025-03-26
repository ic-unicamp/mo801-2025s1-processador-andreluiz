module ProgramCounter(clk, reset, PCWrite, PCNext, PC);

input clk, reset, PCWrite;
//Novo valor de PC;
input [31:0] PCNext;
//Quem receberá o novo valor de PC;
output reg [31:0] PC;

always @ (posedge clk)
begin
if(reset)
	PC = 32'h00000000;
else
	PC = PCNext;
end
endmodule
