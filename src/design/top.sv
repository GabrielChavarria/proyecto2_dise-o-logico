module top (
    input  logic        clk_27mhz,
    input  logic        reset_n,
    output logic [7:0]  segmentos_out,  // [7]=dp, [6:0]={g,f,e,d,c,b,a}
    output logic [3:0]  anodos_out
);

    // numero hardcodeado para probar el display: 1234
    localparam logic [15:0] NUMERO_PRUEBA = {4'd1, 4'd2, 4'd3, 4'd4};

    logic pulso_1khz;

    // divisor de frecuencia: 27MHz -> 1kHz
    divisor_frecuencia #(.N(27000)) div (
        .clk  (clk_27mhz),
        .rst_n(reset_n),
        .pulso(pulso_1khz)
    );

    // controlador del display
    controlador_displays ctrl (
        .clk      (clk_27mhz),
        .rst_n    (reset_n),
        .pulso    (pulso_1khz),
        .numero   (NUMERO_PRUEBA),
        .segmentos(segmentos_out[6:0]),
        .anodos   (anodos_out)
    );

    assign segmentos_out[7] = 1'b0; // punto decimal apagado

endmodule
