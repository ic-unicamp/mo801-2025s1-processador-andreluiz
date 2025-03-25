module loadRegs_RD1_RD2(clk, reset, reg1, reg2, reg1_out, reg2_out, writeData);
input clk, reset;
input [31:0] reg1, reg2;
output reg [31:0] reg1_out, reg2_out, writeData;

always @ (posedge clk)
begin
	if(reset == 1'b1)
	begin
		reg1_out = 32'h0;
		reg2_out = 32'h0;
	end
	else
	begin
		reg1_out = reg1;
		reg2_out = reg2;
	end
end
endmodule
