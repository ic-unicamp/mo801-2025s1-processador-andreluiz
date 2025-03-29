module Controller(clk, reset, opcode, func3, func7, Zero, IRWrite, MemWrite, AdrSrc, PCWrite, RegWrite, ResultSrc, ALUSrcB, ALUSrcA, ImmSrc, ALUControl);
input clk, reset, Zero;

//Inputs do Controller
input [2:0] func3; // 3 bits
input [6:0] opcode, func7; // 7 bits

//Sinais do Controller
output reg IRWrite, MemWrite, AdrSrc, PCWrite, RegWrite; //1 bit
output reg [1:0] ResultSrc, ALUSrcB, ALUSrcA, ImmSrc; //2 bit
output reg [2:0] ALUControl;

reg branch = 0; 

reg [3:0] state;

localparam Fetch             = 4'b0000;
localparam Decode            = 4'b0001;
localparam MemAdr            = 4'b0010;
localparam MemRead           = 4'b0110;
localparam MemWB             = 4'b0111;
localparam MemWrite_state    = 4'b1100;
localparam ExecuteR          = 4'b1010;
localparam ExecuteL          = 4'b1110;
localparam ALUWB             = 4'b1000;
localparam BEQ               = 4'b1001;
localparam JAL               = 4'b1011;

initial begin
	state = 4'b0000;
	AdrSrc = 0; 
	IRWrite = 0; 
	ALUSrcA = 0;
	ALUSrcB = 0; 
	ALUControl = 0;
	ResultSrc = 0;
	RegWrite = 0;
	MemWrite = 0; 
	PCWrite = 0; 
	ImmSrc = 0; 
end

always @ (posedge clk)
begin
	branch = 0;
	case(state)
		Fetch:begin
			AdrSrc = 0; 
			IRWrite = 1; 
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b10; 
			ALUControl = 2'b00;
			ResultSrc = 2'b10; 
			PCWrite = 1; 
			state = Decode;
		end
		Decode:begin
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b10; 
			ALUControl = 2'b00;
			
			case(opcode)
				7'b0000011: state = MemAdr;
				7'b0100011: state = MemAdr;
				7'b0110011: state = ExecuteR;
				7'b0010011: state = ExecuteL;
				7'b1101111: state = JAL;
				7'b1100011: state = BEQ;
				default: state = Fetch;
			endcase
		end
		MemAdr:begin
			ALUSrcA = 2'b10;
			ALUSrcB = 2'b01; 
			ALUControl = 2'b00; 
			
			case(opcode)
				7'b0000011: state = MemRead;
				7'b0100011: state = MemWrite_state;
				default: state = Fetch;
			endcase
			
		end
		MemRead:begin
			AdrSrc = 1; 
			ResultSrc = 2'b10;
			
			state = MemWB;
		end
		MemWB:begin
			ResultSrc = 2'b01;
			RegWrite = 1;
			state = Fetch;
		end
		MemWrite_state:begin
			AdrSrc = 1; 
			ResultSrc = 2'b00;
			MemWrite = 0; 
			state = Fetch;
		end
		ExecuteR:begin
			ALUSrcA = 2'b10;
			ALUSrcB = 2'b00; 
			ALUControl = 2'b10;
			state = ALUWB;
		end
		ExecuteL:begin
			ALUSrcA = 2'b10;
			ALUSrcB = 2'b01; 
			ALUControl = 2'b10;
			state = ALUWB;
		end
		ALUWB:begin
			ResultSrc = 2'b00;
			RegWrite = 1;
			state = Fetch;
		end
		BEQ:begin
			ALUSrcA = 2'b10;
			ALUSrcB = 2'b00; 
			ALUControl = 2'b01;
			ResultSrc = 2'b00;
			branch = 1'b1;
			if(branch == 1'b1 & Zero == 1'b1)
				PCWrite = 1; 
				
			state = Fetch;

		end
		JAL:begin
			ALUSrcA = 2'b01;
			ALUSrcB = 2'b10; 
			ALUControl = 2'b00;
			ResultSrc = 2'b00; 
			PCWrite = 1;  
			state = ALUWB;
		end
		default:begin
			state = 4'b0000;
			AdrSrc = 0; 
			IRWrite = 0; 
			ALUSrcA = 0;
			ALUSrcB = 0; 
			ALUControl = 0;
			ResultSrc = 0;
			RegWrite = 0;
			MemWrite = 0; 
			PCWrite = 0; 
			ImmSrc = 0; 
			state = Fetch;
	end
	endcase
end
endmodule


