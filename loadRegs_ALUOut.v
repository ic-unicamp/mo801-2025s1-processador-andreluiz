module loadRegs_ALUOut(clk, resetn, ALUResult, ALUOut);
input clk, resetn, save;
input [31:0] ALUResult;
output reg [31:0] ALUOut;

always @ (posedge clk)
begin	  
	ALUOut = ALUResult;
end
endmodule
