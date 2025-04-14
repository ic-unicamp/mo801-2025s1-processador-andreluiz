module Multiplex_address(clk, resetn, PC, ALUResult, AdrSrc, address);
input clk, resetn;
input AdrSrc;
input [31:0] PC, ALUResult;
output reg [31:0] address;
 
always @ (*)
begin
	
	if(AdrSrc) begin
	   address = ALUResult;
	end
	else begin
	   address = PC;
	end
end 
endmodule
