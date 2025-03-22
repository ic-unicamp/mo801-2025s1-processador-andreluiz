module programCounter(clk, reset, PCNext, PC);

input clk, reset;
//Novo valor de PC;
input [31:0]PCNext;
//Quem receberá o novo valor de PC;
output reg [31:0] PC;

always @ (posedge clk)
begin
if(reset)
	PC = 32'h00000000;
else
//Atribui novo valor de PC ao próximo PC
	PC = PCNext;
end
endmodule
