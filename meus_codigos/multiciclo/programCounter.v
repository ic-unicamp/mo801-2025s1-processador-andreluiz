module programCounter(clk, reset, PCNext, PC);

input clk, reset;
input [31:0]PCNext;
output reg [31:0] PC;

always @ (posedge clk)
begin
if(reset)
	PC = 32'h00000000;
else
	PC = PCNext;
end
endmodule
