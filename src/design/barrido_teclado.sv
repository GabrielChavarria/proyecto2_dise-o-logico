// =============================================================================
// barrido_teclado.sv
// Escanea filas (salidas) y lee columnas (entradas con pull-up).
// Instancia un módulo debounce por cada columna para eliminar rebotes.
// =============================================================================

module barrido_teclado (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       pulso,        // tick ~1 kHz del divisor_frecuencia
    input  logic [3:0] cols_sync,    // columnas sincronizadas (entradas, pull-up)
    output logic [3:0] filas,        // filas hacia el teclado (una activa en bajo)
    output logic [3:0] fila_cap,     // fila activa al detectar tecla (one-hot, activo bajo)
    output logic [3:0] col_cap,      // columna presionada     (one-hot, activo bajo)
    output logic       tecla_valida  // pulso de 1 ciclo: nueva tecla detectada
);

    // -------------------------------------------------------------------------
    // Anti-rebote: una instancia de debounce por cada columna
    // cols_sync → [debounce x4] → cols_db (señal limpia)
    // -------------------------------------------------------------------------
    logic [3:0] cols_db;

    debounce #(.TICKS(40)) db_col0 (
        .clk      (clk),
        .rst_n    (rst_n),
        .pulso    (pulso),
        .senal_in (cols_sync[0]),
        .senal_out(cols_db[0])
    );

    debounce #(.TICKS(40)) db_col1 (
        .clk      (clk),
        .rst_n    (rst_n),
        .pulso    (pulso),
        .senal_in (cols_sync[1]),
        .senal_out(cols_db[1])
    );

    debounce #(.TICKS(40)) db_col2 (
        .clk      (clk),
        .rst_n    (rst_n),
        .pulso    (pulso),
        .senal_in (cols_sync[2]),
        .senal_out(cols_db[2])
    );

    debounce #(.TICKS(40)) db_col3 (
        .clk      (clk),
        .rst_n    (rst_n),
        .pulso    (pulso),
        .senal_in (cols_sync[3]),
        .senal_out(cols_db[3])
    );

    // -------------------------------------------------------------------------
    // Contador de barrido: activa una fila a la vez en activo bajo
    // Cada fila se mantiene activa 25 pulsos (25 ms) para que el debouncer
    // tenga tiempo suficiente de estabilizar (necesita TICKS=20 pulsos).
    //   estado 0 → filas = 1110  (out_fil[0] → fila 1,2,3,A)
    //   estado 1 → filas = 1101  (out_fil[1] → fila 4,5,6,B)
    //   estado 2 → filas = 1011  (out_fil[2] → fila 7,8,9,C)
    //   estado 3 → filas = 0111  (out_fil[3] → fila *,0,#,D)
    // -------------------------------------------------------------------------
    logic [1:0] estado_fil;
    localparam PULSES_PER_ROW = 50;
    logic [5:0] sub_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            estado_fil <= 2'd0;
            sub_cnt    <= 5'd0;
        end else if (pulso) begin
            if (sub_cnt == PULSES_PER_ROW - 1) begin
                sub_cnt    <= 5'd0;
                estado_fil <= estado_fil + 1;
            end else
                sub_cnt <= sub_cnt + 1;
        end
    end

    always_comb begin
        case (estado_fil)
            2'd0: filas = 4'b1110;
            2'd1: filas = 4'b1101;
            2'd2: filas = 4'b1011;
            2'd3: filas = 4'b0111;
            default: filas = 4'b1111;
        endcase
    end

    // -------------------------------------------------------------------------
    // Captura: se dispara en sub_cnt==23, cuando el debouncer ya tiene
    // 20+ pulsos para estabilizar y antes de que la fila avance (sub_cnt==24).
    // -------------------------------------------------------------------------
    logic captura_en;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            captura_en <= 1'b0;
        else
            captura_en <= pulso && (sub_cnt == PULSES_PER_ROW - 2);
    end

   // tecla_liberada: se pone en 1 solo cuando todas las columnas
    // vuelven a reposo (4'hF), indicando que soltaron la tecla
    logic tecla_liberada;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fila_cap       <= 4'hF;
            col_cap        <= 4'hF;
            tecla_valida   <= 1'b0;
            tecla_liberada <= 1'b1;  // al inicio no hay tecla presionada
        end else begin
            tecla_valida <= 1'b0;

            // Detectar liberación: todas las columnas en reposo
            if (cols_db == 4'hF)
                tecla_liberada <= 1'b1;

            if (captura_en && (cols_db != 4'hF) && tecla_liberada) begin
                fila_cap       <= filas;
                col_cap        <= cols_db;
                tecla_valida   <= 1'b1;
                tecla_liberada <= 1'b0;  // bloquea hasta que suelten
            end
        end
    end

endmodule