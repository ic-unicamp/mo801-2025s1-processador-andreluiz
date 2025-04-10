module ReadData(clk, reset, readData, data);
input clk, reset;
input [31:0] readData;
output reg [31:0] data;

initial begin
	data= readData;
end
endmodule;

