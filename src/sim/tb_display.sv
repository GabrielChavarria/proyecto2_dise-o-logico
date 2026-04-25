module tb_display;

    logic        clk;
    logic        reset_n;
    logic [7:0]  segmentos_out;
    logic [3:0]  anodos_out;

    // instancia del top
    top dut (
        .clk_27mhz    (clk),
        .reset_n      (reset_n),
        .segmentos_out(segmentos_out),
        .anodos_out   (anodos_out)
    );

    // reloj de 27MHz -> periodo de 37ns
    initial clk = 0;
    always #18.5 clk = ~clk;

    // tarea para imprimir el estado actual
    task mostrar_estado;
        string seg_str;
        case (segmentos_out[6:0])
            7'b0111111: seg_str = "0";
            7'b0000110: seg_str = "1";
            7'b1011011: seg_str = "2";
            7'b1001111: seg_str = "3";
            7'b1100110: seg_str = "4";
            7'b1101101: seg_str = "5";
            7'b1111101: seg_str = "6";
            7'b0000111: seg_str = "7";
            7'b1111111: seg_str = "8";
            7'b1101111: seg_str = "9";
            default:    seg_str = "?";
        endcase
        $display("t=%0t | anodos=%b | segmentos=%b | digito=%s",
                  $time, anodos_out, segmentos_out[6:0], seg_str);
    endtask

    initial begin
        // reset inicial
        reset_n = 0;
        repeat(5) @(posedge clk);
        reset_n = 1;

        // esperar suficientes ciclos para ver los 4 digitos refrescarse
        // 1kHz = un cambio cada 27000 ciclos, 4 digitos = 108000 ciclos
        repeat(120000) @(posedge clk);

        $display("--- Simulacion completada ---");
        $finish;
    end

    // monitorear cada cambio de anodo
    always @(anodos_out) begin
        mostrar_estado();
    end

endmodule
