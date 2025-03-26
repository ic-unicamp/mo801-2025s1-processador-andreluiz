module Multiplex_address(clk, reset, PC, ALUResult, AdrSrc, address);
input clk, reset;
input AdrSrc;
input [31:0] PC, ALUResult;
output reg [31:0] address;
 
always @ (posedge clk)
begin
	if(AdrSrc)
	   address = ALUResult;
	else
	   address = PC;
end 
endmodule
