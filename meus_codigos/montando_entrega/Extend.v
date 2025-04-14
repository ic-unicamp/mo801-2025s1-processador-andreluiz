module Extend(clk, reset, immValue, immSrc, immExt);

input clk, reset; 
input [2:0] immSrc;
input [24:0] immValue;

output reg [31:0] immExt;

always @ (posedge clk)
begin
	case(immSrc)
		3'b000 : immExt = {{20{immValue[24]}},immValue[24:13]}; //L-type 
		3'b001 : immExt = {{20{immValue[24]}},immValue[24:18],immValue[4:0]}; //S-type
		3'b010 : immExt = $signed({immValue[24],immValue[0],immValue[23:18],immValue[4:1],1'b0}); //B-type
		3'b011 : immExt = $signed({immValue[24],immValue[12:5],immValue[13],immValue[23:14],1'b0}); //J-type
		3'b100 : immExt = {immValue[24:5],12'b0}; //LUI-type
		3'b101 : immExt = immValue[17:13]; //L-typ --- SRAI, SLLI SRLI
		default : immExt = 32'b0; //R type
	endcase
	//$display("immSrc: %b, immExt: %d, immValue: %b",immSrc,immExt,immValue);
end

endmodule
