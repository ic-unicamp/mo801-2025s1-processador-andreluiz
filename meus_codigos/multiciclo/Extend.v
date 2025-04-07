module Extend(clk, reset, immValue, immSrc, immExt);

input clk, reset; 
input [1:0] immSrc;
input [24:0] immValue;

output reg [31:0] immExt;

always @ (posedge clk)
begin
	case(immSrc)
		2'b00 : immExt = immValue[24:13]; //L-type 
		2'b01 : immExt = {immValue[24:18],immValue[4:0]}; //S-type
		2'b10 : immExt = {immValue[24:18],immValue[4:1]}; //B-type
		default : immExt = 32'b0; //R type
	endcase
	$display("immSrc: %b, immExt: %d",immSrc,immExt);
end

endmodule
