
module fsm_entrada_datos (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       tecla_valida,
    input  logic [3:0] digito,
    input  logic       es_numero,
    input  logic       confirmar_a,
    input  logic       ejecutar,
    input  logic       limpiar,
    output logic [9:0] operando_a,
    output logic [9:0] operando_b,
    output logic       suma_valida,
    output logic [1:0] estado_dbg
);
    typedef enum logic [1:0] {
        INGRESO_A  = 2'd0,
        INGRESO_B  = 2'd1,
        RESULTADO  = 2'd2,
        IDLE       = 2'd3
    } estado_t;
 
    estado_t estado, estado_sig;
 
    logic [9:0] reg_a, reg_b;
    logic [1:0] cuenta_digitos;
    logic       suma_valida_next;
 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            estado         <= IDLE;
            reg_a          <= 10'd0;
            reg_b          <= 10'd0;
            cuenta_digitos <= 2'd0;
            suma_valida    <= 1'b0;
        end else begin
            suma_valida <= suma_valida_next;
            estado      <= estado_sig;
            if (tecla_valida) begin
                if (limpiar) begin
                    reg_a          <= 10'd0;
                    reg_b          <= 10'd0;
                    cuenta_digitos <= 2'd0;
                end else begin
                    case (estado)
                        IDLE: begin
                            reg_a          <= 10'd0;
                            reg_b          <= 10'd0;
                            cuenta_digitos <= 2'd0;
                            if (es_numero) begin
                                reg_a          <= {6'd0, digito};
                                cuenta_digitos <= 2'd1;
                            end
                        end
                        INGRESO_A: begin
                            if (es_numero && cuenta_digitos < 2'd3) begin
                                reg_a          <= reg_a * 10 + {6'd0, digito};
                                cuenta_digitos <= cuenta_digitos + 1;
                            end
                            if (confirmar_a) begin
                                cuenta_digitos <= 2'd0;
                            end
                        end
                        INGRESO_B: begin
                            if (es_numero && cuenta_digitos < 2'd3) begin
                                reg_b          <= reg_b * 10 + {6'd0, digito};
                                cuenta_digitos <= cuenta_digitos + 1;
                            end
                        end
                        RESULTADO: ;
                        default: ;
                    endcase
                end
            end
        end
    end
 
    always_comb begin
        estado_sig       = estado;
        suma_valida_next = 1'b0;
        if (tecla_valida) begin
            if (limpiar) begin
                estado_sig = IDLE;
            end else begin
                case (estado)
                    IDLE:      if (es_numero)  estado_sig = INGRESO_A;
                    INGRESO_A: if (confirmar_a) estado_sig = INGRESO_B;
                    INGRESO_B: if (ejecutar) begin
                        estado_sig       = RESULTADO;
                        suma_valida_next = 1'b1;
                    end
                    RESULTADO: ;
                    default: estado_sig = IDLE;
                endcase
            end
        end
    end
 
    assign operando_a = reg_a;
    assign operando_b = reg_b;
    assign estado_dbg = estado;
 
endmodule
