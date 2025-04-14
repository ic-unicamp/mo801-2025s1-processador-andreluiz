module ALU(clk, reset, srcA, srcB, ALUControl, Zero, ALUResult);

input clk, reset;
//Inputs srcA e srcB que serão os elementos da operação da ALU;
input [31:0] srcA, srcB;
//Entrada que determina qual operação da ALU será realizada;
input [9:0] ALUControl;
//Zero: Quando Zero e a condicional branch do controller são verdadeiros, o comando BEQ pode escrever informações no ProgramCounter
output reg Zero;
//Saída que recebera o resultado da operação da ALU realizada entre srcA e srcB e determinada pela ALUControl;
output reg [31:0] ALUResult;

localparam ADD               = 10'b0000000000;
localparam SUB               = 10'b0100000000;
localparam SLL               = 10'b0000000001;
localparam SLT               = 10'b0000000010;
localparam SLTU              = 10'b0000000011;
localparam XOR               = 10'b0000000100;
localparam SRL               = 10'b0000000101;
localparam SRA               = 10'b0100000101;
localparam OR                = 10'b0000000110;
localparam AND               = 10'b0000000111;
localparam BEQ               = 10'b0000001000;
localparam BNE               = 10'b0000001001;
localparam BLT               = 10'b0000001010;
localparam BGE               = 10'b0000001011;
localparam BLTU              = 10'b0000001100;
localparam BGEU              = 10'b0000001101;
localparam LUI               = 10'b0000001110;

//Quando qualquer um dos elementos for modificado...
always @ (*)
begin
	//Decide a operação que será realizada. As determinação das operações foi feita a partir de uma tabela;
	//Caso a entrada não se pareça com nenhuma opção do case, o resultado de ALUResult será um registrador zerado;
	case(ALUControl)
		ADD : ALUResult = srcA + srcB;
		SUB : ALUResult = srcA - srcB;
		SLL : ALUResult = srcA << srcB;
		SLT : ALUResult = ($signed(srcA) < $signed(srcB))?32'b1:32'b0;
		SLTU: ALUResult = (srcA < srcB)?32'b1:32'b0;
		XOR : ALUResult = srcA ^ srcB;
		SRL : ALUResult = srcA >> srcB;
		SRA : ALUResult = $signed(srcA) >> srcB;
		OR  : ALUResult = srcA | srcB;
		AND : ALUResult = srcA & srcB;
		BEQ :begin 
			ALUResult = srcA - srcB;
			Zero = (ALUResult == 0)?1:0;
		        //$display("BRANCH EQUAL; ZERO = %b; ALUResult = %d", Zero, ALUResult);
		end
		BNE :begin 
			ALUResult = srcA - srcB;
			Zero = (ALUResult != 0)?1:0;
		        //$display("BRANCH NOT EQUAL; ZERO = %b; ALUResult = %d", Zero, ALUResult); 
		end
		BLT :begin 
			ALUResult = srcA - srcB;
			Zero = ($signed(ALUResult) < 0)?1:0;
		        //$display("BRANCH LESS THAN; ZERO = %b; ALUResult = %d", Zero, ALUResult);
		end
		BGE :begin 
			ALUResult = srcA - srcB;
			Zero = ($signed(ALUResult) >= 0)?1:0;
		        //$display("BRANCH GREATER OR EQUAL; ZERO = %b; ALUResult = %d", Zero, ALUResult);
		end
		BLTU:begin 
			ALUResult = srcA - srcB;
			Zero = (ALUResult < 0)?1:0;
		        //$display("BRANCH LESS THAN UNSIGNED; ZERO = %b; ALUResult = %d", Zero, ALUResult);
		end
		BGEU:begin 
			ALUResult = srcA - srcB;
			Zero = (ALUResult >= 0)?1:0;
		        //$display("BRANCH GREATER OR EQUAL UNSIGNED; ZERO = %b; ALUResult = %d", Zero, ALUResult);
		end
		LUI:ALUResult = srcB;
		default : ALUResult = 32'h0;
	endcase
	if(ALUControl == BLTU)
		$display("SrcA:%d SrcB:%d = ALUR:%d\n-------",srcA,srcB,ALUResult);
end

always @ (posedge clk) begin
	Zero = 0;
end


endmodule
