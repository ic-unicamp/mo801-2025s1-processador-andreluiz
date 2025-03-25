module ALU(clk, reset, srcA, srcB, ALUControl, Zero, ALUResult);

input clk, reset, Zero;
//Inputs srcA e srcB que serão os elementos da operação da ALU;
input [31:0] srcA, srcB;
//Entrada que determina qual operação da ALU será realizada;
input [2:0] ALUControl;
//Saída que recebera o resultado da operação da ALU realizada entre srcA e srcB e determinada pela ALUControl;
output reg [31:0] ALUResult;

//Quando qualquer um dos elementos for modificado...
always @ (*)
begin
	if(reset==1'b1 | Zero)
	begin
		ALUResult = 32'h0;
	end
	else
	begin
		//Decide a operação que será realizada. As determinação das operações foi feita a partir de uma tabela;
		//Caso a entrada não se pareça com nenhuma opção do case, o resultado de ALUResult será um registrador zerado;
		case(ALUControl)
			2'b00 : ALUResult = srcA & srcB;
			2'b01 : ALUResult = srcA | srcB;
			2'b10 : ALUResult = srcA + srcB;
			2'b11 : ALUResult = srcA - srcB;
			default : ALUResult = 32'h0;
		endcase
	end
	$display ("srcA = %d, srcB = %d",srcA,srcB);
	$display ("The operation is %b, the result is %d",ALUControl,ALUResult);
end

endmodule
