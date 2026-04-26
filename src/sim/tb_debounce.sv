module tb_debounce;

    logic clk;
    logic rst_n;
    logic pulso;
    logic senal_in;
    logic senal_out;

    // instancia del debounce
    debounce #(.TICKS(20)) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .pulso    (pulso),
        .senal_in (senal_in),
        .senal_out(senal_out)
    );

    // reloj 27MHz -> periodo 37ns
    initial clk = 0;
    always #18.5 clk = ~clk;

    // generador de pulso 1kHz (cada 27000 ciclos)
    integer cont_pulso = 0;
    always_ff @(posedge clk) begin
        if (cont_pulso == 26999) begin
            cont_pulso <= 0;
            pulso <= 1'b1;
        end else begin
            cont_pulso <= cont_pulso + 1;
            pulso <= 1'b0;
        end
    end

    // tarea para simular rebote
    task simular_rebote(input logic valor_final);
        integer i;
        for (i = 0; i < 5; i++) begin
            senal_in = ~valor_final;
            #2000000; // 2ms
            senal_in = valor_final;
            #2000000; // 2ms
        end
        senal_in = valor_final;
        #25000000; // estable 25ms
    endtask

    initial begin
        $dumpfile("tb_debounce.vcd");
        $dumpvars(0, tb_debounce);

        rst_n    = 0;
        senal_in = 1'b1;
        #100;
        rst_n = 1;
        #1000000;

        $display("--- Prueba 1: tecla presionada con rebote ---");
        $display("senal_out antes: %b", senal_out);
        simular_rebote(1'b0);
        $display("senal_out despues de estabilizar: %b", senal_out);

        #5000000;

        $display("--- Prueba 2: tecla soltada con rebote ---");
        simular_rebote(1'b1);
        $display("senal_out al soltar: %b", senal_out);

        $display("--- Simulacion completada ---");
        $finish;
    end

    always @(senal_out)
        $display("t=%0t | senal_in=%b | senal_out=%b", $time, senal_in, senal_out);

endmodule
