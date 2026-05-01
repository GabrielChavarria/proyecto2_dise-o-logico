module tb_display;

    logic        clk;
    logic        rst_n;
    logic        pulso;
    logic [6:0]  segmentos;
    logic [3:0]  anodos;

    // numero hardcodeado para prueba: 1234
    localparam logic [15:0] NUMERO = {4'd1, 4'd2, 4'd3, 4'd4};

    // instancia divisor de frecuencia
    divisor_frecuencia #(.N(27000)) div (
        .clk  (clk),
        .rst_n(rst_n),
        .pulso(pulso)
    );

    // instancia controlador de displays
    controlador_displays ctrl (
        .clk      (clk),
        .rst_n    (rst_n),
        .pulso    (pulso),
        .numero   (NUMERO),
        .segmentos(segmentos),
        .anodos   (anodos)
    );

    // reloj 27MHz -> periodo 37ns
    initial clk = 0;
    always #18.5 clk = ~clk;

    // tarea para mostrar el digito activo
    task mostrar_estado;
        string seg_str;
        case (segmentos)
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
                  $time, anodos, segmentos, seg_str);
    endtask

    initial begin
        $dumpfile("tb_display.vcd");
        $dumpvars(0, tb_display);

        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;

        repeat(450000) @(posedge clk);

        $display("--- Simulacion completada ---");
        $finish;
    end

    // monitorear cambios en anodos
    always @(anodos) begin
        mostrar_estado();
    end

endmodule
