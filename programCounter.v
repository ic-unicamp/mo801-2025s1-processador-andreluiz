module ProgramCounter(clk, resetn, PCWrite, PCNext, PC);

input clk, resetn, PCWrite;
//Novo valor de PC;
input [31:0] PCNext;
//Quem receberá o novo valor de PC;
output reg [31:0] PC;

always @ (PCWrite) begin
	//$display("MUDOU PCWRITE PARA %b",PCWrite);
end


always @ (posedge clk)
begin
if(resetn == 1'b0) begin
	PC = 32'h00000000;
end else
	if(PCWrite == 1'b1) begin
           //$display("PC: %d; PCNext: %d",PC, PCNext);
   	   PC = PCNext;
	end
end
endmodule
