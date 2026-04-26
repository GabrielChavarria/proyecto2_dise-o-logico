module debounce #(
    parameter TICKS = 20  // ciclos de 1kHz a esperar (~20ms)
)(
    input  logic clk,
    input  logic rst_n,
    input  logic pulso,       // enable 1kHz del divisor_frecuencia
    input  logic senal_in,    // señal sincronizada del teclado
    output logic senal_out    // señal limpia sin rebote
);

    logic [$clog2(TICKS)-1:0] contador;
    logic estado_actual;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            contador      <= '0;
            estado_actual <= 1'b1;  // reposo con pull-up = alto
            senal_out     <= 1'b1;
        end else if (pulso) begin
            if (senal_in == estado_actual) begin
                contador <= '0;
            end else begin
                if (contador == TICKS - 1) begin
                    estado_actual <= senal_in;
                    senal_out     <= senal_in;
                    contador      <= '0;
                end else begin
                    contador <= contador + 1;
                end
            end
        end
    end

endmodule
