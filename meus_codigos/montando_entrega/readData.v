module ReadData_regHandler(clk, reset, func3_variant, readData, data);
input clk, reset;
input [31:0] readData;
input [2:0] func3_variant;
output [31:0] data;

//assign data = (func3_variant==3'b000)?{{24{readData[7]}},readData[7:0]}:(func3_variant==3'b001)?{{16{readData[15]}},readData[15:0]}:(func3_variant==3'b100)?readData[7:0]:(func3_variant==3'b101)?readData[15:0]:readData;

assign data = readData;

endmodule;

