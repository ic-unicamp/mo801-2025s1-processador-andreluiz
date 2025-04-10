module Controller(clk, reset, opcode, func3, func7, Zero, IRWrite, MemWrite, AdrSrc, PCWrite, RegWrite, ResultSrc, ALUSrcB, ALUSrcA, ImmSrc, ALUControl);
input clk, reset, Zero;

//Inputs do Controller
input [2:0] func3; // 3 bits
input [6:0] opcode, func7; // 7 bits

//Sinais do Controller
output reg IRWrite, MemWrite, AdrSrc, PCWrite, RegWrite; //1 bit
output reg [1:0] ResultSrc, ALUSrcB, ALUSrcA, ImmSrc; //2 bit
output reg [9:0] ALUControl;

reg branch = 0; 

reg [3:0] state;

localparam Fetch             = 5'b00000;
localparam Decode            = 5'b00001;
localparam MemAdr            = 5'b00010;
localparam MemRead           = 5'b00110;
localparam MemWB             = 5'b00111;
localparam MemWrite_state    = 5'b01100;
localparam ExecuteR          = 5'b01010;
localparam ExecuteL          = 5'b01110;
localparam ALUWB             = 5'b01000;
localparam BEQ               = 5'b01001;
localparam JAL               = 5'b01011;
localparam AUIPC             = 5'b01100;
localparam LUI               = 5'b01101;
localparam Fetch_CalculatePC    = 5'b01111;

initial begin
	state = 5'b11111;//Default
end

always @ (Zero) begin
    $display("OLHA QUI, BRANCH = %b e ZERO = %b",branch,Zero);
    if(branch == 1'b1 & Zero == 1'b1)
	PCWrite = 1; 
    else
        PCWrite = 0;
end

always @ (opcode) begin
	case(opcode)
		7'b0000011: ImmSrc = 2'b00;
		7'b0100011: ImmSrc = 2'b01;
		7'b0010011: ImmSrc = 2'b00;
		7'b1100011: ImmSrc = 2'b10;
		7'b1101111: ImmSrc = 2'b11;
		default: ImmSrc = 2'b00;
	endcase
end

always @ (posedge clk)
begin
//$display("IRWrite = %b, MemWrite = %b, AdrSrc = %b, PCWrite = %b, RegWrite = %b; ResultSrc = %b, ALUSrcB = %b, ALUSrcA = %b, ImmSrc = %b, ALUControl = %b\n", IRWrite, MemWrite, AdrSrc, PCWrite, RegWrite, ResultSrc, ALUSrcB, ALUSrcA, ImmSrc, ALUControl);
//$display("PCWrite = %b; IRWrite = %b; RegWrite = %b",PCWrite, IRWrite, RegWrite);
	if(reset == 1'b0) begin
		state = 5'b01111;
	end else begin	

		branch = 0;
		case(state)
			Fetch_CalculatePC:begin
				$display("====Fetch_CalculatePC====");
				AdrSrc = 0; 
				IRWrite = 0; 
				ALUSrcA = 2'b00;
				ALUSrcB = 2'b10; 
				ALUControl = 2'b00;
				ResultSrc = 2'b10; 
				RegWrite = 0;
				PCWrite = 0; 
				state = Fetch; 
			end
			Fetch:begin
				$display("====Fetch====");
				AdrSrc = 0; 
				IRWrite = 1; 
				ALUSrcA = 2'b00;
				ALUSrcB = 2'b10; 
				ALUControl = 2'b00;
				ResultSrc = 2'b10; 
				RegWrite = 0;
				PCWrite = 1; 
				state = Decode;
			end
			Decode:begin
				$display("====Decode====");
				PCWrite = 0;
				IRWrite = 0;
				MemWrite = 0;
				RegWrite = 0;
				ALUSrcA = 2'b01;
				ALUSrcB = 2'b01;
				case(opcode)
					7'b0000011: state = MemAdr;
					7'b0100011: state = MemAdr;
					7'b0110011: state = ExecuteR;
					7'b0010011: state = ExecuteL;
					7'b1101111: state = JAL;
					7'b1100011: state = BEQ;
					7'b0010111: state = AUIPC;
					7'b0110111: state = LUI;
					default: state = Fetch_CalculatePC;
				endcase
			end
			MemAdr:begin
				$display("====MemAdr====");
				ALUSrcA = 2'b10;
				ALUSrcB = 2'b01; 
				ALUControl = 10'b0000000000; 
				
				case(opcode)
					7'b0000011: state = MemRead;
					7'b0100011: state = MemWrite_state;
					default: state = Fetch_CalculatePC;
				endcase
				
			end
			MemRead:begin
				$display("====MemRead====");
				AdrSrc = 1; 
				ResultSrc = 2'b10;
				
				state = MemWB;
			end
			MemWB:begin
				$display("====MemWB====");
				ResultSrc = 2'b01;
				RegWrite = 1;
				#10;
				state = Fetch_CalculatePC;
			end
			MemWrite_state:begin
				$display("====MemWrite====");
				AdrSrc = 1; 
				ResultSrc = 2'b00;
				MemWrite = 1;
				state = Fetch_CalculatePC;
			end
			ExecuteR:begin
				$display("====ExecuteR====");
				ALUSrcA = 2'b10;
				ALUSrcB = 2'b00; 
				ALUControl = {func7,func3};
				state = ALUWB;
			end
			ExecuteL:begin
				$display("====ExecuteL====");
				PCWrite = 0;
				MemWrite = 0;
				IRWrite = 0;
				RegWrite = 0;
				ALUSrcA = 2'b10;
				ALUSrcB = 2'b01; 
				ALUControl = func3;
				state = ALUWB;
			end
			ALUWB:begin
				$display("====ALUWB====");
				PCWrite = 0;
				MemWrite = 0;
				IRWrite = 0;
				ResultSrc = 2'b00;
				RegWrite = 1;
				state = Fetch_CalculatePC;
			end
			BEQ:begin
				$display("====BEQ --- Zero: %b====",Zero);
				ALUSrcA = 2'b10;
				ALUSrcB = 2'b00; 
				case(func3)
					3'b000:ALUControl = 10'b0000001000;
					3'b001:ALUControl = 10'b0000001001;
					3'b100:ALUControl = 10'b0000001010;
					3'b101:ALUControl = 10'b0000001011;
				endcase
				ResultSrc = 2'b00;
				branch = 1'b1;					
				state = Fetch_CalculatePC;

			end
			JAL:begin
				$display("====JAL====");
				ALUSrcA = 2'b01;
				ALUSrcB = 2'b10; 
				ALUControl = 2'b00;
				ResultSrc = 2'b00; 
				PCWrite = 1;  
				state = ALUWB;
			end
			AUIPC:begin
				$display("====AUIPC====");
				ALUSrcA = 2'b01;
				ALUSrcB = 2'b10; 
				ALUControl = 2'b00;
				ResultSrc = 2'b00; 
				PCWrite = 1;  
				state = ALUWB;
			end
			LUI:begin
				$display("====LUI====");
				ALUSrcA = 2'b01;
				ALUSrcB = 2'b10; 
				ALUControl = 2'b00;
				ResultSrc = 2'b00; 
				PCWrite = 1;  
				state = ALUWB;
			end
			default:begin
				$display("====Default====");
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
				state = Fetch_CalculatePC;
			end
		endcase
		$display("Branch:%b",branch);
	end
end
endmodule


