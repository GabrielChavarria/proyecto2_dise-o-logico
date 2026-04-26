module controlador_displays (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        pulso,        // enable de 1kHz del divisor_frecuencia
    input  logic [15:0] numero,       // {digito3, digito2, digito1, digito0} en BCD
    output logic [6:0]  segmentos,    // {g,f,e,d,c,b,a} al display
    output logic [3:0]  anodos        // un bit por digito, activo en bajo (catodo comun)
);

    logic [1:0] digito_activo;
    logic [3:0] bcd_actual;

    // contador de digito activo
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            digito_activo <= 2'd0;
        else if (pulso)
            digito_activo <= digito_activo + 1;
    end

    // seleccion del digito BCD a mostrar
    always_comb begin
        case (digito_activo)
            2'd0: bcd_actual = numero[15:12]; // digito izquierda
            2'd1: bcd_actual = numero[11:8];
            2'd2: bcd_actual = numero[7:4];
            2'd3: bcd_actual = numero[3:0];   // digito derecha
            default: bcd_actual = 4'd0;
        endcase
    end

    // activacion del catodo correspondiente (activo en bajo para catodo comun)
    always_comb begin
        case (digito_activo)
            2'd0: anodos = 4'b1110; // digito 1 activo
            2'd1: anodos = 4'b1101; // digito 2 activo
            2'd2: anodos = 4'b1011; // digito 3 activo
            2'd3: anodos = 4'b0111; // digito 4 activo
            default: anodos = 4'b1111; // todos apagados
        endcase
    end

    // instancia del decodificador
    decodificador_7seg dec (
        .bcd      (bcd_actual),
        .segmentos(segmentos)
    );

endmodule
