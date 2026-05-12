
`timescale 1ns/1ps

module tb_sumador;
    logic clk;
    logic rst_n;
    logic [9:0]  operando_a, operando_b;
    logic        suma_valida;
    logic [10:0] resultado;
    int errores = 0;

    sumador dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .operando_a  (operando_a),
        .operando_b  (operando_b),
        .suma_valida (suma_valida),
        .resultado   (resultado)
    );

    initial clk = 0;
    always #18 clk = ~clk;

    task sumar(input [9:0] a, input [9:0] b, input [10:0] esperado);
        @(negedge clk);
        operando_a  = a;
        operando_b  = b;
        suma_valida = 1;
        @(posedge clk);
        @(negedge clk);
        suma_valida = 0;
        #1;
        if (resultado !== esperado) begin
            $display("[FAIL] %0d + %0d = %0d (esperado %0d)",
                     a, b, resultado, esperado);
            errores++;
        end else begin
            $display("[PASS] %0d + %0d = %0d", a, b, resultado);
        end
    endtask

    initial begin
        $dumpfile("tb_sumador.vcd");
        $dumpvars(0, tb_sumador);

        rst_n = 0;
        operando_a = 0; operando_b = 0; suma_valida = 0;
        repeat (3) @(posedge clk);
        #1;
        if (resultado !== 11'd0) begin
            $display("[FAIL] reset no inicializa resultado en 0");
            errores++;
        end else $display("[PASS] reset: resultado=0");

        @(negedge clk); rst_n = 1;
        @(posedge clk);

        // Casos basicos
        sumar(10'd0,   10'd0,   11'd0);
        sumar(10'd1,   10'd1,   11'd2);
        sumar(10'd100, 10'd200, 11'd300);
        sumar(10'd123, 10'd456, 11'd579);     // caso de prueba del proyecto
        sumar(10'd500, 10'd500, 11'd1000);
        sumar(10'd999, 10'd0,   11'd999);     // operando B en cero
        sumar(10'd0,   10'd999, 11'd999);     // operando A en cero
        sumar(10'd999, 10'd999, 11'd1998);    // maximo 3 digitos decimales
        sumar(10'd1023, 10'd1023, 11'd2046);  // maximo 10 bits

        // Test: suma_valida bajo no debe alterar el resultado
        @(negedge clk);
        operando_a = 10'd99; operando_b = 10'd99; suma_valida = 0;
        @(posedge clk);
        @(posedge clk);
        #1;
        if (resultado !== 11'd2046) begin
            $display("[FAIL] resultado cambio sin suma_valida (es %0d)", resultado);
            errores++;
        end else $display("[PASS] mantiene resultado sin suma_valida");

        // Test: reset asincronico durante operacion
        @(negedge clk);
        operando_a = 10'd55; operando_b = 10'd55; suma_valida = 1;
        rst_n = 0;
        @(posedge clk);
        #1;
        if (resultado !== 11'd0) begin
            $display("[FAIL] reset asincronico no limpio resultado");
            errores++;
        end else $display("[PASS] reset asincronico limpia resultado");

        @(negedge clk); rst_n = 1; suma_valida = 0;

        $display("");
        if (errores == 0)
            $display("=== tb_sumador: TODOS LOS TESTS PASARON ===");
        else
            $display("=== tb_sumador: %0d FALLOS ===", errores);
        $finish;
    end

    initial begin
        #20000;
        $display("[TIMEOUT] tb_sumador");
        $finish;
    end
endmodule