module decodificador_7seg (
    input  logic [3:0] bcd,
    output logic [6:0] segmentos  // {g, f, e, d, c, b, a}
);
    always_comb begin
        case (bcd)
            4'd0: segmentos = 7'b0111111; // a,b,c,d,e,f ON  g OFF
            4'd1: segmentos = 7'b0000110; // b,c ON
            4'd2: segmentos = 7'b1011011; // a,b,d,e,g ON
            4'd3: segmentos = 7'b1001111; // a,b,c,d,g ON
            4'd4: segmentos = 7'b1100110; // b,c,f,g ON
            4'd5: segmentos = 7'b1101101; // a,c,d,f,g ON
            4'd6: segmentos = 7'b1111101; // a,c,d,e,f,g ON
            4'd7: segmentos = 7'b0000111; // a,b,c ON
            4'd8: segmentos = 7'b1111111; // todos ON
            4'd9: segmentos = 7'b1101111; // a,b,c,d,f,g ON
            default: segmentos = 7'b0000000; // apagado
        endcase
    end
endmodule
