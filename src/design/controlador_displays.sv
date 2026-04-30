module controlador_displays (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        pulso,        // ~1 kHz del divisor_frecuencia
    input  logic [15:0] numero,       // {miles, centenas, decenas, unidades} en BCD
    output logic [6:0]  segmentos,    // {g,f,e,d,c,b,a} → mapear a seg[6:0] en top
    output logic [3:0]  anodos        // activo en bajo → conectar a dig[3:0]
);
    logic [1:0] digito_activo;
    logic [3:0] bcd_actual;
    logic [3:0] digitos [0:3];
 
    assign digitos[0] = numero[15:12]; // miles    (D1, izquierda)
    assign digitos[1] = numero[11:8];  // centenas (D2)
    assign digitos[2] = numero[7:4];   // decenas  (D3)
    assign digitos[3] = numero[3:0];   // unidades (D4, derecha)
 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            digito_activo <= 2'd0;
        else if (pulso)
            digito_activo <= digito_activo + 1;
    end
 
    assign bcd_actual = digitos[digito_activo];
 
    always_comb begin
        case (digito_activo)
            2'd0: anodos = 4'b1110; // D1 activo (dig[0] = 0)
            2'd1: anodos = 4'b1101; // D2 activo (dig[1] = 0)
            2'd2: anodos = 4'b1011; // D3 activo (dig[2] = 0)
            2'd3: anodos = 4'b0111; // D4 activo (dig[3] = 0)
            default: anodos = 4'b1111;
        endcase
    end
 
    decodificador_7seg dec (
        .bcd      (bcd_actual),
        .segmentos(segmentos)
    );
endmodule
