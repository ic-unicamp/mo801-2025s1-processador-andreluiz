module loadRegs_oneInput_oneOutput(clk, reset, singleInput, singleOutput);
input clk, reset;
input [31:0] singleInput;
output reg [31:0] singleOutput;

always @ (posedge clk)
begin
	if(reset == 1'b1)
	begin
		singleOutput = 32'h0;
	end
	else
	begin
		singleOutput = singleInput;
	end
end
endmodule
