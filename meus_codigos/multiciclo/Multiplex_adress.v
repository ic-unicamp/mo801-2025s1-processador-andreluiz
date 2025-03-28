module Multiplex_address(clk, reset, PC, ALUResult, AdrSrc, address);
input clk, reset;
input AdrSrc;
input [31:0] PC, ALUResult;
output reg [31:0] address;
 
always @ (posedge clk)
begin
	if(reset) begin
	   address = 32'h0;
	end;
	
	if(AdrSrc) begin
	   address = ALUResult;
	end
	else begin
	   address = PC;
	end
end 
endmodule
