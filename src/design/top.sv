module top (
    input  logic        clk_27mhz,     // 27 MHz - pin 52
    input  logic        reset_n,       // S1 integrado - pin 88

    // Teclado
    input  logic [3:0]  in_col,        // columnas (pull-up interno, reposo=1111)
    output logic [3:0]  out_fil,       // filas (una activa en bajo a la vez)

    // Display (catodo comun)
    output logic [7:0]  segmentos_out, // segmentos_out[0]=a ... [6]=g, [7]=dp
    output logic [3:0]  anodos_out     // anodos_out[0]=D1 ... [3]=D4, activo en bajo
);

    // Reset interno automatico al arrancar
    logic        rst_n_int;
    logic [3:0]  rst_cnt = 4'd0;
    always_ff @(posedge clk_27mhz) begin
        if (!(&rst_cnt))
            rst_cnt <= rst_cnt + 1;
    end
    assign rst_n_int = (&rst_cnt) & reset_n;

    // Señales internas
    logic [3:0] cols_sync;
    logic       pulso_tick;
    logic [3:0] fila_cap;
    logic [3:0] col_cap;
    logic       tecla_valida;

    logic [3:0] digito;
    logic       es_numero;
    logic       confirmar_a;
    logic       ejecutar;
    logic       limpiar;

    logic [9:0]  operando_a;
    logic [9:0]  operando_b;
    logic        suma_valida;
    logic [1:0]  estado_dbg;
    logic [10:0] resultado;

    logic [10:0] num_display;
    logic [3:0]  d_miles;
    logic [3:0]  d_cientos;
    logic [3:0]  d_decenas;
    logic [3:0]  d_unidades;
    logic [15:0] numero_bcd;
    logic [6:0]  segs_internos;

    // Sincronizador de columnas
    sincronizador #(.BITS(4)) sync_cols (
        .clk         (clk_27mhz),
        .senal_async (in_col),
        .senal_sync  (cols_sync)
    );

    // Divisor de frecuencia 27MHz -> 1kHz
    divisor_frecuencia #(.N(27000)) div_tick (
        .clk   (clk_27mhz),
        .rst_n (rst_n_int),
        .pulso (pulso_tick)
    );

    // Barrido del teclado
    barrido_teclado barrido (
        .clk          (clk_27mhz),
        .rst_n        (reset_n),
        .pulso        (pulso_tick),
        .cols_sync    (cols_sync),
        .filas        (out_fil),
        .fila_cap     (fila_cap),
        .col_cap      (col_cap),
        .tecla_valida (tecla_valida)
    );

    // Decodificador de tecla
    decodificador_tecla deco_tecla (
        .fila_cap    (fila_cap),
        .col_cap     (col_cap),
        .digito      (digito),
        .es_numero   (es_numero),
        .confirmar_a (confirmar_a),
        .ejecutar    (ejecutar),
        .limpiar     (limpiar)
    );

    // FSM de entrada de datos
    fsm_entrada_datos fsm (
        .clk          (clk_27mhz),
        .rst_n        (reset_n),
        .tecla_valida (tecla_valida),
        .digito       (digito),
        .es_numero    (es_numero),
        .confirmar_a  (confirmar_a),
        .ejecutar     (ejecutar),
        .limpiar      (limpiar),
        .operando_a   (operando_a),
        .operando_b   (operando_b),
        .suma_valida  (suma_valida),
        .estado_dbg   (estado_dbg)
    );

    // Sumador
    sumador sum (
        .clk         (clk_27mhz),
        .rst_n       (reset_n),
        .operando_a  (operando_a),
        .operando_b  (operando_b),
        .suma_valida (suma_valida),
        .resultado   (resultado)
    );

    // Conversion binario a BCD para el display
    always_comb begin
        case (estado_dbg)
            2'd0:    num_display = {1'b0, operando_a};
            2'd1:    num_display = {1'b0, operando_b};
            2'd2:    num_display = resultado;
            default: num_display = 11'd0;
        endcase

        d_miles    =  num_display / 11'd1000;
        d_cientos  = (num_display % 11'd1000) / 11'd100;
        d_decenas  = (num_display % 11'd100)  / 11'd10;
        d_unidades =  num_display % 11'd10;
    end

    assign numero_bcd = {d_miles, d_cientos, d_decenas, d_unidades};

    // Controlador del display
    controlador_displays ctrl_disp (
        .clk       (clk_27mhz),
        .rst_n     (reset_n),
        .pulso     (pulso_tick),
        .numero    (numero_bcd),
        .segmentos (segs_internos),
        .anodos    (anodos_out)
    );

    // Conexion segmentos {a,b,c,d,e,f,g}
    assign segmentos_out[0] = segs_internos[0]; // a
    assign segmentos_out[1] = segs_internos[1]; // b
    assign segmentos_out[2] = segs_internos[2]; // c
    assign segmentos_out[3] = segs_internos[3]; // d
    assign segmentos_out[4] = segs_internos[4]; // e
    assign segmentos_out[5] = segs_internos[5]; // f
    assign segmentos_out[6] = segs_internos[6]; // g
    assign segmentos_out[7] = 1'b0;             // dp apagado

endmodule
