module sincronizador #(
    parameter BITS = 4
)(
    input  logic             clk,
    input  logic [BITS-1:0]  senal_async,
    output logic [BITS-1:0]  senal_sync
);

    logic [BITS-1:0] ff1;

    always_ff @(posedge clk) begin
        ff1        <= senal_async;
        senal_sync <= ff1;
    end

endmodule