module Extend(clk, reset, immValue, immSrc, immExt_l);

input clk, reset; 
input [1:0] immSrc;
input [24:0] immValue;

//Saída para funções do tipo L
output reg [11:0] immExt_l;


always @ (posedge clk)
begin

	case(immSrc)
		2'b00 : immExt_l = immValue[24:13];
		default : immExt_l = 32'h0;
	endcase

end

endmodule
