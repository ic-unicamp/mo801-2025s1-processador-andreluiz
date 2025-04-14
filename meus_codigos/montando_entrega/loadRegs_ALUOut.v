module loadRegs_ALUOut(clk, reset, ALUResult, ALUOut);
input clk, reset, save;
input [31:0] ALUResult;
output reg [31:0] ALUOut;

always @ (posedge clk)
begin	  
	ALUOut = ALUResult;
end
endmodule
