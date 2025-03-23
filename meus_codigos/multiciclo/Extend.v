module Extend(clk, reset, immValue, immSrc, immExt);

input clk, reset, immSrc;
input [24:0] immValue;

output reg [24:0] immExt;

always @ (posedge clk)
begin
if(immSrc == 1'b1)
	immExt = immValue;
end

endmodule
