module sumador (
    input  logic        clk,//relog del sistema
    input  logic        rst_n,// cuando reset activo en bajo
    input  logic [9:0]  operando_a,// operandos de 10 bits
    input  logic [9:0]  operando_b,//
    input  logic        suma_valida,//
    output logic [10:0] resultado
);
    always_ff @(posedge clk or negedge rst_n) begin// define como flip-flop  
        if (!rst_n)//¿reset activo?
            resultado <= 11'd0; // si hay reset se pone en 0
        else if (suma_valida)// si no hay reset, revisa si suma_valida esta activa
            resultado <= {1'b0, operando_a} + {1'b0, operando_b};// esto hace la suma 
    end
endmodule
