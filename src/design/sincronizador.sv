module sincronizador #(
    parameter BITS = 4  // numero de señales a sincronizar
)(
    input  logic             clk,
    input  logic [BITS-1:0]  señal_async,  // señales del teclado sin sincronizar
    output logic [BITS-1:0]  señal_sync    // señales sincronizadas al reloj
);

    logic [BITS-1:0] ff1;  // primer flip-flop

    always_ff @(posedge clk) begin
        ff1        <= señal_async;  // primer FF: puede quedar metaestable
        señal_sync <= ff1;          // segundo FF: ya estabilizado
    end

endmodule
