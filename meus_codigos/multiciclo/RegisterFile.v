module RegisterFile(clk,reset,A1,A2,A3,WD3,WE3,RD1,RD2);

input clk,reset,WE3;

//Respectivamente rs1, rs2 e rd;
input [4:0] A1;
input [4:0] A2;
input [4:0] A3;
input [31:0] WD3;

//Respectivamente Write Data(para o caso do WE3 estar como true), saída do primeiro registrador e saída do segundo registrador;
output [31:0] RD1;
output [31:0] RD2;

//Vetor de registradores. Temos 32 registradores cujas dimensões são 32 bits;
reg [31:0] Registers[31:0];
integer k;

//Associa às saídas RD1 e RD2 os valores no índice A1 e A2, respectivamente, do meu vetor de registradores;
assign RD1 = Registers[A1];
assign RD2 = Registers[A2];

initial begin
	for(k=0; k<32; k = k + 1)
	begin
		Registers[k] = 32'h0;
	end
end

always @ (posedge clk)
begin
	if(reset)
	begin
		for(k=0; k<32; k = k + 1)
		begin
			Registers[k] = 32'h0;
		end
	end
	else if(WE3 == 1'b1)
	begin
		Registers[A3] = WD3;
	end
end
endmodule
