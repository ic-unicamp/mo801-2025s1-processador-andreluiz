module RegisterFile(clk,resetn,A1,A2,A3,WD3,WE3,RD1,RD2);

input clk,resetn,WE3;

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

always @ (WE3)
begin
	if(WE3 == 1'b1 & A3 > 0)
	begin
		Registers[A3] = WD3;
		//$display("atualiza A3(%d) com valor %d", A3, Registers[A3]);
	end
	//$display(" x01=%b\n x02=%b\n x03=%b\n x04=%b\n x05=%b\n x06=%b\n x06=%b\n x08=%b\n x09=%b\n x10=%b\n x11=%b\n x12=%b\n x13=%b",Registers[1],Registers[2],Registers[3],Registers[4],Registers[5],Registers[6],Registers[7],Registers[8],Registers[9],Registers[10],Registers[11],Registers[12],Registers[13]);
end
endmodule
