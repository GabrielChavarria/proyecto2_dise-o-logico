// =============================================================================
// tb_top.sv
// Testbench del sistema completo (integracion)
// Simula la calculadora calculando: 123 + 456 = 579
//
// Pinout:
//   - clk_27mhz: reloj del Tang Nano 9k
//   - reset_n:   reset activo bajo
//   - in_col:    columnas del teclado matricial
//   - out_fil:   filas del teclado matricial
//   - segmentos_out / anodos_out: 4 displays multiplexados
//
// Para acelerar la simulacion se usan defparam que reducen N del divisor
// y TICKS del debounce. El comportamiento funcional es identico al original.
// =============================================================================
`timescale 1ns/1ps

module tb_top;
    logic clk_27mhz;
    logic reset_n;
    logic [3:0] in_col;
    logic [3:0] out_fil;
    logic [7:0] segmentos_out;
    logic [3:0] anodos_out;
    int errores = 0;

    // Emulacion del teclado matricial
    logic [3:0] tecla_fila;   // 4'hF = nada presionada
    logic [3:0] tecla_col;

    assign in_col = (tecla_fila == 4'hF) ? 4'hF :
                    (out_fil == tecla_fila) ? tecla_col : 4'hF;

    top dut (
        .clk_27mhz     (clk_27mhz),
        .reset_n       (reset_n),
        .in_col        (in_col),
        .out_fil       (out_fil),
        .segmentos_out (segmentos_out),
        .anodos_out    (anodos_out)
    );

    // ========================================================================
    // Aceleracion de la simulacion via defparam
    // Reduce el divisor de 27000 -> 27 (1 MHz en vez de 1 kHz)
    // y los debounce TICKS de 20 -> 5.
    // Esto hace la simulacion ~1000x mas rapida sin cambiar el comportamiento.
    // ========================================================================
    defparam dut.div_tick.N           = 27;
    defparam dut.barrido.db_col0.TICKS = 5;
    defparam dut.barrido.db_col1.TICKS = 5;
    defparam dut.barrido.db_col2.TICKS = 5;
    defparam dut.barrido.db_col3.TICKS = 5;

    // Reloj de 27 MHz
    initial clk_27mhz = 0;
    always #18 clk_27mhz = ~clk_27mhz;

    // Tarea para presionar y soltar una tecla
    task presionar(input [3:0] fila, input [3:0] col, input string nombre);
        int timeout_count;
        @(negedge clk_27mhz);
        tecla_fila = fila;
        tecla_col  = col;
        timeout_count = 0;
        while (!dut.tecla_valida && timeout_count < 30000) begin
            @(posedge clk_27mhz);
            timeout_count++;
        end
        if (!dut.tecla_valida) begin
            $display("[FAIL] %s: timeout esperando tecla_valida", nombre);
            errores++;
        end else $display("[PASS] %s: tecla detectada @ %0t ns",
                          nombre, $time/1000);
        @(posedge clk_27mhz);
        // Soltar
        @(negedge clk_27mhz);
        tecla_fila = 4'hF;
        tecla_col  = 4'hF;
        // Esperar a que tecla_liberada vuelva a 1 (multiple barridos completos)
        // PULSES_PER_ROW=50, 4 filas, release_cnt necesita 25 con filas==fila_cap
        // Con N=27 (1 pulso/us), espera ~10000 ciclos (~370 us = ~2 barridos completos)
        repeat (15000) @(posedge clk_27mhz);
    endtask

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);

        reset_n    = 0;
        tecla_fila = 4'hF;
        tecla_col  = 4'hF;

        repeat (50) @(posedge clk_27mhz);
        @(negedge clk_27mhz); reset_n = 1;
        // Esperar a que termine el power-on reset interno (rst_cnt[3:0])
        repeat (100) @(posedge clk_27mhz);

        $display("");
        $display("============================================================");
        $display("  Secuencia de prueba: 123 + 456 = 579");
        $display("============================================================");

        // Ingresar 123
        presionar(4'b1110, 4'b1110, "tecla_1");
        presionar(4'b1110, 4'b1101, "tecla_2");
        presionar(4'b1110, 4'b1011, "tecla_3");

        // Verificacion intermedia
        if (dut.operando_a !== 10'd123) begin
            $display("[FAIL] operando_a = %0d (esp 123)", dut.operando_a);
            errores++;
        end else $display("[PASS] operando_a = 123");

        // Confirmar (A)
        presionar(4'b1110, 4'b0111, "tecla_A_(suma)");
        if (dut.estado_dbg !== 2'd1) begin
            $display("[FAIL] no paso a INGRESO_B, estado=%0d", dut.estado_dbg);
            errores++;
        end else $display("[PASS] paso a INGRESO_B tras tecla A");

        // Ingresar 456
        presionar(4'b1101, 4'b1110, "tecla_4");
        presionar(4'b1101, 4'b1101, "tecla_5");
        presionar(4'b1101, 4'b1011, "tecla_6");

        if (dut.operando_b !== 10'd456) begin
            $display("[FAIL] operando_b = %0d (esp 456)", dut.operando_b);
            errores++;
        end else $display("[PASS] operando_b = 456");

        // Ejecutar (B)
        presionar(4'b1101, 4'b0111, "tecla_B_(igual)");

        // Esperar a que la suma se complete
        repeat (50) @(posedge clk_27mhz);

        if (dut.resultado !== 11'd579) begin
            $display("[FAIL] resultado = %0d (esp 579)", dut.resultado);
            errores++;
        end else begin
            $display("");
            $display("============================================================");
            $display("  [PASS] 123 + 456 = %0d", dut.resultado);
            $display("============================================================");
        end

        if (dut.estado_dbg !== 2'd2) begin
            $display("[FAIL] no paso a RESULTADO, estado=%0d", dut.estado_dbg);
            errores++;
        end else $display("[PASS] estado RESULTADO mostrado en displays");

        // Verificar que el sistema activo los anodos durante la simulacion
        if (anodos_out === 4'hF || anodos_out === 4'h0) begin
            $display("[FAIL] anodos_out estancado en %b", anodos_out);
            errores++;
        end else $display("[PASS] anodos_out activo: %b", anodos_out);

        // Limpiar (D)
        $display("");
        $display("--- Limpiar (tecla D) ---");
        presionar(4'b0111, 4'b0111, "tecla_D_(limpiar)");

        if (dut.operando_a !== 0 || dut.operando_b !== 0) begin
            $display("[FAIL] limpiar no funciono"); errores++;
        end else $display("[PASS] sistema limpio tras D");
        if (dut.estado_dbg !== 2'd3) begin
            $display("[FAIL] no volvio a IDLE, estado=%0d", dut.estado_dbg);
            errores++;
        end else $display("[PASS] volvio a IDLE");

        // Segunda prueba: 999 + 1 = 1000 (overflow a 4 digitos)
        $display("");
        $display("============================================================");
        $display("  Segunda prueba: 999 + 1 = 1000");
        $display("============================================================");

        presionar(4'b1011, 4'b1011, "tecla_9");
        presionar(4'b1011, 4'b1011, "tecla_9");
        presionar(4'b1011, 4'b1011, "tecla_9");
        presionar(4'b1110, 4'b0111, "tecla_A");
        presionar(4'b1110, 4'b1110, "tecla_1");
        presionar(4'b1101, 4'b0111, "tecla_B");
        repeat (50) @(posedge clk_27mhz);

        if (dut.resultado !== 11'd1000) begin
            $display("[FAIL] 999+1 = %0d (esp 1000)", dut.resultado);
            errores++;
        end else $display("[PASS] 999 + 1 = 1000");

        $display("");
        $display("============================================================");
        if (errores == 0)
            $display("  tb_top: TODOS LOS TESTS PASARON");
        else
            $display("  tb_top: %0d FALLOS", errores);
        $display("============================================================");
        $finish;
    end

    initial begin
        #500_000_000;     // 500 ms simulados maximo
        $display("[TIMEOUT] tb_top excedio limite de tiempo");
        $finish;
    end
endmodule