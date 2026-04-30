module sumador (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [9:0]  operando_a,
    input  logic [9:0]  operando_b,
    input  logic        suma_valida,
    output logic [10:0] resultado
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            resultado <= 11'd0;
        else if (suma_valida)
            resultado <= {1'b0, operando_a} + {1'b0, operando_b};
    end
endmodule
