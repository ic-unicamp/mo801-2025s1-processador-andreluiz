module Multiplex(clk, reset, ALUSrc, opt1, opt2, opt3, result);

input clk, reset;
input [1:0] ALUSrc;
input [31:0] opt1, opt2, opt3;

output reg [31:0] result;

always @ (*)
begin
        //$display("ALUSrc: %b",ALUSrc);
	case(ALUSrc)
	     2'b00 : result = opt1;
	     2'b01 : result = opt2;
	     2'b10 : result = opt3;
	     default : result = 32'h0;
	endcase
	//$display("result: %d",result);
end
endmodule
