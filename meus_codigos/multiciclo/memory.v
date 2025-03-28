module memory(
  input [31:0] address,
  input [31:0] data_in,
  output reg [31:0] data_out,
  input we
);

reg [31:0] mem[0:1024]; // 16KB de memória
integer i;

always @(address or data_in or we) begin
  if (we) begin
    mem[address] = data_in;
  end
  mem[677] = 32'b00000000010000010010000110000011;
  mem[1] = 32'b00000000000000000000000001000000;
  data_out = mem[address[13:2]];
end


initial begin
  for (i = 0; i < 1024; i = i + 1) begin
    mem[i] = 32'h00000000;
  end
  
  //$readmemh("memory.mem", mem);
end

endmodule
