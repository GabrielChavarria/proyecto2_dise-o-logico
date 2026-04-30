module divisor_frecuencia #(
    parameter N = 27000
)(
    input  logic clk,
    input  logic rst_n,
    output logic pulso
);
    logic [$clog2(N)-1:0] contador;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            contador <= '0;
            pulso    <= 1'b0;
        end else if (contador == N - 1) begin
            contador <= '0;
            pulso    <= 1'b1;
        end else begin
            contador <= contador + 1;
            pulso    <= 1'b0;
        end
    end
endmodule
