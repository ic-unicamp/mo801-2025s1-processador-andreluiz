module Testbench;
reg clk, reset, AdrSrc;
reg [31:0] PC, ALUResult;
wire [31:0] address;

// Instanciação do módulo
Multiplex_address uut (
    .clk(clk),
    .reset(reset),
    .PC(PC),
    .ALUResult(ALUResult),
    .AdrSrc(AdrSrc),
    .address(address)
);

initial begin
    clk = 0;
    reset = 0;
    PC = 32'h0000_0001;
    ALUResult = 32'h0000_0010;
    AdrSrc = 0;
    #10;
    clk = 1;
    #10;
    clk = 2;
    #10;
end
endmodule

