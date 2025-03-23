module RISCV;

    // Sinais
    reg clk, reset, immSrc;
    reg [4:0] A1, A2, A3; // Índices de registradores corrigidos para 5 bits
    reg WE3;              // Habilita escrita no RegisterFile
    reg [31:0] WD3;       // Dado a ser escrito no registrador
    wire [31:0] RD1, RD2; // Dados lidos dos registradores
    reg [24:0] immValue;
    wire [31:0] result_multiplex_PC_oldPC_RD1, result_multiplex_RD2_immExt_4;

    reg [31:0] srcA, srcB; // Operandos da ALU
    reg [1:0] ALUControl, ALUSrcA, ALUSrcB;  // Controle da operação da ALU
    wire Zero;             // Flag Zero da ALU
    wire [31:0] ALUResult; // Resultado da ALU
    wire [31:0] immExt;
    reg [31:0] PC, oldPC;

    // Instância do RegisterFile
    RegisterFile regfile_inst (
        .clk(clk),
        .reset(reset),
        .A1(A1),
        .A2(A2),
        .A3(A3),
        .WD3(WD3),
        .WE3(WE3),
        .RD1(RD1),
        .RD2(RD2)
    );
    
    Extend extend(
        .clk(clk),
        .reset(reset),
        .immValue(immValue), 
        .immSrc(immSrc), 
        .immExt(immExt)
    );

    Multiplex multiplex_RD2_immExt_4 (
    	.clk(clk),
    	.reset(reset),
    	.ALUSrc(ALUSrcB),
    	.opt1(RD2),
    	.opt2(immExt),
    	.opt3(32'd4),
    	.result(result_multiplex_RD2_immExt_4)
    );
    
    Multiplex multiplex_PC_oldPC_RD1 (
    	.clk(clk),
    	.reset(reset),
    	.ALUSrc(ALUSrcA),
    	.opt1(PC),
    	.opt2(oldPC),
    	.opt3(RD1),
    	.result(result_multiplex_PC_oldPC_RD1)
    );

    // Instância do ALU
    ALU alu_inst (
        .clk(clk),
        .reset(reset),
        .srcA(result_multiplex_PC_oldPC_RD1),
        .srcB(result_multiplex_RD2_immExt_4),
        .ALUControl(ALUControl),
        .Zero(Zero),
        .ALUResult(ALUResult)
    );

    // Gerador de clock
    initial begin
        clk = 0;
    end

    // Simulação inicial
	initial begin
	    // Passo 1: Configuração inicial
	    reset = 1;
	    immSrc = 1;
	    #10 reset = 0;
	    clk = 1;	
	    // Passo 2: Escrevendo o valor 30 no registrador A1
	    A3 = 5'd2;        // Defina A3 para indicar o índice (por exemplo, 2)
	    WD3 = 32'd30;     // Valor a ser escrito
	    WE3 = 1'b1;       // Habilita escrita
	    #10 WE3 = 1'b0;   // Desabilita escrita após o ciclo
            clk = 2;
	    // Passo 3: Lendo o valor do registrador A1
	    A1 = 5'd2;        // Defina A1 para acessar o registrador escrito
	    A2 = 5'd2;
	    immValue = 24'd15;
	    PC = 32'd5;
	    oldPC = 32'd4;
	    #10;
	    clk = 3;
	    ALUControl = 2'b10;
	    ALUSrcB = 2'b10;
	    ALUSrcA = 2'b01;
  
	    // Passo 4: Verificar se o valor lido é igual a 30
	    $display("Valor em Registers[A1]: %d; Registers[A2]: %d; immExt: %d; ALUResult: %d", RD1, RD2, immExt, ALUResult);
	end


    // Monitoramento
    initial begin
        $monitor("RD1 = %d, RD2 = %d, ALUResult = %d", 
                 RD1, RD2, ALUResult);
    end

endmodule

