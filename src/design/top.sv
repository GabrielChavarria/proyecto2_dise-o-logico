module top (
    input  logic        clk,           // 27 MHz – pin 52

    // ── Teclado ──────────────────────────────────────────────────────────────
    input  logic [3:0]  in_col,        // columnas (pull-up → reposo=1111)
    output logic [3:0]  out_fil,       // filas    (una activa en bajo a la vez)

    // ── Display 5641AS cat_odo común ──────────────────────────────────────────
    output logic [7:0]  seg,           // seg[0]=A … seg[6]=G, seg[7]=DP
    output logic [3:0]  dig            // dig[0]=D1 … dig[3]=D4, activo en bajo
);

   

    // Subsistema teclado
    logic [3:0] cols_sync;
    logic       pulso_tick;
    logic [3:0] fila_cap;
    logic [3:0] col_cap;
    logic       tecla_valida;

    // Decodificador de tecla
    logic [3:0] digito;
    logic       es_numero;
    logic       confirmar_a;
    logic       ejecutar;
    logic       limpiar;

    // FSM
    logic [9:0] operando_a;
    logic [9:0] operando_b;
    logic       suma_valida;
    logic [1:0] estado_dbg;

    // Sumador
    logic [10:0] resultado;

    // Display
    logic [10:0] num_display;
    logic [3:0]  d_miles;
    logic [3:0]  d_cientos;
    logic [3:0]  d_decenas;
    logic [3:0]  d_unidades;
    logic [15:0] numero_bcd;

    logic [6:0]  segs_internos;

    
    logic rst_n;
    logic [3:0] rst_cnt = 4'd0;

    always_ff @(posedge clk) begin
        if (!(&rst_cnt))
            rst_cnt <= rst_cnt + 1;
    end
    assign rst_n = &rst_cnt;

    
    sincronizador #(.BITS(4)) sync_cols (
        .clk         (clk),
        .senal_async (in_col),
        .senal_sync  (cols_sync)
    );

    
    divisor_frecuencia #(.N(27000)) div_tick (
        .clk   (clk),
        .rst_n (rst_n),
        .pulso (pulso_tick)
    );

    
    barrido_teclado barrido (
        .clk          (clk),
        .rst_n        (rst_n),
        .pulso        (pulso_tick),
        .cols_sync    (cols_sync),
        .filas        (out_fil),
        .fila_cap     (fila_cap),
        .col_cap      (col_cap),
        .tecla_valida (tecla_valida)
    );

    
    decodificador_tecla deco_tecla (
        .fila_cap    (fila_cap),
        .col_cap     (col_cap),
        .digito      (digito),
        .es_numero   (es_numero),
        .confirmar_a (confirmar_a),
        .ejecutar    (ejecutar),
        .limpiar     (limpiar)
    );

    
    fsm_entrada_datos fsm (
        .clk          (clk),
        .rst_n        (rst_n),
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

    
    sumador sum (
        .clk         (clk),
        .rst_n       (rst_n),
        .operando_a  (operando_a),
        .operando_b  (operando_b),
        .suma_valida (suma_valida),
        .resultado   (resultado)
    );

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

   
    controlador_displays ctrl_disp (
        .clk       (clk),
        .rst_n     (rst_n),
        .pulso     (pulso_tick),
        .numero    (numero_bcd),
        .segmentos (segs_internos),
        .anodos    (dig)
    );

   
    assign seg[0] = segs_internos[0]; // A
    assign seg[1] = segs_internos[1]; // B
    assign seg[2] = segs_internos[2]; // C
    assign seg[3] = segs_internos[3]; // D
    assign seg[4] = segs_internos[4]; // E
    assign seg[5] = segs_internos[5]; // F
    assign seg[6] = segs_internos[6]; // G
    assign seg[7] = 1'b0;             // DP siempre apagado

endmodule