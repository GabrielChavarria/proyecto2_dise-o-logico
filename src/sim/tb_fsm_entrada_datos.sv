
`timescale 1ns/1ps

module tb_fsm_entrada_datos;
    logic clk;
    logic rst_n;
    logic tecla_valida;
    logic [3:0] digito;
    logic es_numero, confirmar_a, ejecutar, limpiar;
    logic [9:0] operando_a, operando_b;
    logic suma_valida;
    logic [1:0] estado_dbg;
    int errores = 0;

    fsm_entrada_datos dut (
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

    initial clk = 0;
    always #18 clk = ~clk;

    // Codificacion de estados (debe coincidir con la del DUT)
    localparam INGRESO_A = 2'd0;
    localparam INGRESO_B = 2'd1;
    localparam RESULTADO = 2'd2;
    localparam IDLE      = 2'd3;

    task enviar_digito(input [3:0] d);
        @(negedge clk);
        digito = d; es_numero = 1; tecla_valida = 1;
        @(posedge clk);
        @(negedge clk);
        tecla_valida = 0; es_numero = 0;
    endtask

    task enviar_cmd(input bit cf, input bit ex, input bit lp);
        @(negedge clk);
        confirmar_a = cf; ejecutar = ex; limpiar = lp; tecla_valida = 1;
        @(posedge clk);
        @(negedge clk);
        tecla_valida = 0; confirmar_a = 0; ejecutar = 0; limpiar = 0;
    endtask

    task verificar_estado(input [1:0] esp, input string nombre);
        if (estado_dbg !== esp) begin
            $display("[FAIL] %s: estado=%0d (esp %0d)", nombre, estado_dbg, esp);
            errores++;
        end else $display("[PASS] %s: estado correcto", nombre);
    endtask

    initial begin
        $dumpfile("tb_fsm_entrada_datos.vcd");
        $dumpvars(0, tb_fsm_entrada_datos);

        rst_n = 0;
        tecla_valida = 0; digito = 0; es_numero = 0;
        confirmar_a = 0; ejecutar = 0; limpiar = 0;
        repeat (3) @(posedge clk);
        #1;
        verificar_estado(IDLE, "reset_IDLE");
        if (operando_a !== 0 || operando_b !== 0) begin
            $display("[FAIL] reset: operandos no en 0"); errores++;
        end else $display("[PASS] reset: operandos en 0");

        @(negedge clk); rst_n = 1;
        @(posedge clk);

        // ===== Secuencia principal: 123 + 456 = 579 =====
        $display("");
        $display("--- Secuencia 123 + 456 = 579 ---");

        enviar_digito(1);
        @(posedge clk); #1;
        verificar_estado(INGRESO_A, "tras_digito_1_estado_INGRESO_A");
        if (operando_a !== 10'd1) begin
            $display("[FAIL] operando_a=%0d (esp 1)", operando_a); errores++;
        end else $display("[PASS] operando_a = 1");

        enviar_digito(2);
        enviar_digito(3);
        @(posedge clk); #1;
        if (operando_a !== 10'd123) begin
            $display("[FAIL] operando_a=%0d (esp 123)", operando_a); errores++;
        end else $display("[PASS] operando_a = 123");
        verificar_estado(INGRESO_A, "tras_123_sigue_INGRESO_A");

        enviar_cmd(1, 0, 0);    // confirmar A
        @(posedge clk); #1;
        verificar_estado(INGRESO_B, "tras_A_estado_INGRESO_B");

        enviar_digito(4);
        enviar_digito(5);
        enviar_digito(6);
        @(posedge clk); #1;
        if (operando_b !== 10'd456) begin
            $display("[FAIL] operando_b=%0d (esp 456)", operando_b); errores++;
        end else $display("[PASS] operando_b = 456");
        verificar_estado(INGRESO_B, "tras_456_sigue_INGRESO_B");

        enviar_cmd(0, 1, 0);    // ejecutar
        @(posedge clk); #1;
        verificar_estado(RESULTADO, "tras_B_estado_RESULTADO");

        enviar_cmd(0, 0, 1);    // limpiar
        @(posedge clk); #1;
        verificar_estado(IDLE, "tras_D_estado_IDLE");
        if (operando_a !== 0 || operando_b !== 0) begin
            $display("[FAIL] limpiar no resetea operandos: A=%0d B=%0d",
                     operando_a, operando_b);
            errores++;
        end else $display("[PASS] limpiar resetea operandos");

        // ===== Test: limite de 3 digitos =====
        $display("");
        $display("--- Test limite 3 digitos ---");

        enviar_digito(7);
        enviar_digito(8);
        enviar_digito(9);
        @(posedge clk); #1;
        if (operando_a !== 10'd789) begin
            $display("[FAIL] tras 789 operando_a=%0d", operando_a); errores++;
        end else $display("[PASS] operando_a = 789");

        enviar_digito(5);   // 4to digito: debe ignorarse
        @(posedge clk); #1;
        if (operando_a !== 10'd789) begin
            $display("[FAIL] 4to digito acepto: operando_a=%0d (esp 789)",
                     operando_a);
            errores++;
        end else $display("[PASS] 4to digito ignorado, operando_a=789");

        // Limpiar para siguiente test
        enviar_cmd(0, 0, 1);

        // ===== Test: tecla_valida=0 no causa cambios =====
        $display("");
        $display("--- Test tecla_valida=0 ---");

        @(negedge clk);
        digito = 9; es_numero = 1; tecla_valida = 0;  // no asserted
        repeat (5) @(posedge clk);
        #1;
        verificar_estado(IDLE, "sin_tecla_valida_sigue_IDLE");
        if (operando_a !== 0) begin
            $display("[FAIL] cambio sin tecla_valida"); errores++;
        end else $display("[PASS] sin tecla_valida, no cambia");

        // ===== Test: limpiar desde cualquier estado =====
        $display("");
        $display("--- Test limpiar global ---");

        enviar_digito(2);
        enviar_digito(5);
        enviar_cmd(1, 0, 0);   // pasa a INGRESO_B
        enviar_digito(7);
        @(posedge clk); #1;
        verificar_estado(INGRESO_B, "antes_de_limpiar_INGRESO_B");

        enviar_cmd(0, 0, 1);   // limpiar desde INGRESO_B
        @(posedge clk); #1;
        verificar_estado(IDLE, "limpiar_desde_INGRESO_B");
        if (operando_a !== 0 || operando_b !== 0) begin
            $display("[FAIL] limpiar global no funciono"); errores++;
        end else $display("[PASS] limpiar global desde INGRESO_B");

        // ===== Test: suma con operando 0 =====
        $display("");
        $display("--- Test suma con operando 0 ---");

        enviar_digito(0);       // operando_a = 0
        @(posedge clk); #1;
        verificar_estado(INGRESO_A, "0_transiciona_a_INGRESO_A");
        enviar_cmd(1, 0, 0);    // confirmar
        enviar_digito(5);       // operando_b = 5
        enviar_cmd(0, 1, 0);    // ejecutar
        @(posedge clk); #1;
        if (operando_a !== 0 || operando_b !== 5) begin
            $display("[FAIL] 0+5: A=%0d B=%0d", operando_a, operando_b);
            errores++;
        end else $display("[PASS] operandos para 0+5 correctos");

        $display("");
        if (errores == 0)
            $display("=== tb_fsm_entrada_datos: TODOS LOS TESTS PASARON ===");
        else
            $display("=== tb_fsm_entrada_datos: %0d FALLOS ===", errores);
        $finish;
    end

    initial begin
        #100000;
        $display("[TIMEOUT] tb_fsm_entrada_datos");
        $finish;
    end
endmodule