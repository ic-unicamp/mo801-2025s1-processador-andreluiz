module loadRegs_ALUOut(clk, reset, save, ALUResult, ALUOut);
input clk, reset, save;
input [31:0] ALUResult;
output reg [31:0] ALUOut;

always @ (posedge clk)
begin
	if(reset == 1'b1)
	  ALUOut = 32'h0;
	else if(save == 1'b1)
	  ALUOut = ALUResult;
end
endmodule
