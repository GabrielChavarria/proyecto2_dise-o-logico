module debounce #(
    parameter TICKS = 20  // ciclos de 1kHz a esperar (~20ms)
)(
    input  logic clk,
    input  logic rst_n,
    input  logic pulso,       // activa 1kHz del divisor_frecuencia
    input  logic señal_in,    // señal sincronizada del teclado
    output logic señal_out    // señal limpia sin rebote
);

    logic [$clog2(TICKS)-1:0] contador;
    logic estado_actual;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            contador     <= '0;
            estado_actual <= 1'b1;  // reposo con pull-up = alto
            señal_out    <= 1'b1;
        end else if (pulso) begin
            if (señal_in == estado_actual) begin
                // señal cambio -> reiniciar contador
                contador <= '0;
            end else begin
                if (contador == TICKS - 1) begin
                    // señal estable por TICKS ciclos -> aceptar cambio
                    estado_actual <= señal_in;
                    señal_out     <= señal_in;
                    contador      <= '0;
                end else begin
                    contador <= contador + 1;
                end
            end
        end
    end

endmodule
