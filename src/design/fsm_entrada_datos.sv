//Modulo que controla el ingreso de fatos usando una FSM 
//su trabajo es 
//recibir datos
//construir el operando_a
//construir el operando_b
//activar la suma cuando el usuario lo indique 


module fsm_entrada_datos (
    input  logic       clk,//relog del sistema
    input  logic       rst_n,// reset activo en bajo
    input  logic       tecla_valida,//indica que se presiono una tecla valida, de todas ;las que tienen el teclado
    input  logic [3:0] digito,//numero ingresado, representado usando 4 bits,de 0 a 15
    input  logic       es_numero,// indica si la tecla corresponde a un numero
    input  logic       confirmar_a,//señal que indica que ya se termino de ingresar el primer numero (A)
    input  logic       ejecutar,//indica que debe relizar la suma
    input  logic       limpiar,//reinicia el modulo
    output logic [9:0] operando_a,//operandos
    output logic [9:0] operando_b,
    output logic       suma_valida,// indica que los operandos estan listos para hacer la suma
    output logic [1:0] estado_dbg//salida para depuracion 
);
    typedef enum logic [1:0] {// define un tipo enumerado para los estados
        INGRESO_A  = 2'd0,// estado donse se pone el primer numero
        INGRESO_B  = 2'd1,//estado donde se pone el segundo numero
        RESULTADO  = 2'd2,//estado despues de ejecutar la suma
        IDLE       = 2'd3//estado inicial
    } estado_t;
 
    estado_t estado, estado_sig;//estado = estado actual, estado_sig = siguiente estado
 
    logic [9:0] reg_a, reg_b;//guarda los operandos 
    logic [1:0] cuenta_digitos;//cuenta cuantos diditos sean ingresado
    logic       suma_valida_next;//version combinacional de suma_valida
 
    always_ff @(posedge clk or negedge rst_n) begin // logica sincronizada 
        if (!rst_n) begin// si reset esta activo
            estado         <= IDLE;//Fsm en IDLE
            reg_a          <= 10'd0;//borra operandos
            reg_b          <= 10'd0;//
            cuenta_digitos <= 2'd0;//reinicia el contador
            suma_valida    <= 1'b0;//desactia suma
        end else begin
            suma_valida <= suma_valida_next;//actualiza la salida de validacion 
            estado      <= estado_sig;// actualiza el estado
            if (tecla_valida) begin// indica que solo procesa entradas cuando una tecla es valida 
                if (limpiar) begin// si se presiona limpiar, se borra todo
                    reg_a          <= 10'd0;//
                    reg_b          <= 10'd0;//
                    cuenta_digitos <= 2'd0;//
                end else begin
                    case (estado)// maquina de estados, dependiendo dele stado actual 
                        IDLE: begin// estado incial, limpia operandos
                            reg_a          <= 10'd0;
                            reg_b          <= 10'd0;
                            cuenta_digitos <= 2'd0;
                            if (es_numero) begin //si se ingreso un numero
                                reg_a          <= {6'd0, digito};// guarda el primer digito en reg_a
                                cuenta_digitos <= 2'd1;// dice que ahora hay un digito ingresado
                            end
                        end
                        INGRESO_A: begin//sigue agregando digitos al operando A
                            if (es_numero && cuenta_digitos < 2'd3) begin//solo acepta maximo 3 digitos
                                reg_a          <= reg_a * 10 + {6'd0, digito};//construye un numero decimal
                                cuenta_digitos <= cuenta_digitos + 1;//incrementa el contador 
                            end
                            if (confirmar_a) begin//si usuario confirma A
                                cuenta_digitos <= 2'd0;// se reinicia el contador para ingresar B
                            end
                        end
                        INGRESO_B: begin
                            if (es_numero && cuenta_digitos < 2'd3) begin
                                reg_b          <= reg_b * 10 + {6'd0, digito};// forma el segundo operando
                                cuenta_digitos <= cuenta_digitos + 1;//
                            end
                        end
                        RESULTADO: ;//estado resultado, se detiene aqui
                        default: ;
                    endcase
                end
            end
        end
    end
 
    always_comb begin//determina siguiente estado y señáles 
        estado_sig       = estado;// por defecto mantiene el estado actual
        suma_valida_next = 1'b0;//por defecto no activar el modulo de suma
        if (tecla_valida) begin
            if (limpiar) begin
                estado_sig = IDLE;
            end else begin
                case (estado)
                    IDLE:      if (es_numero)  estado_sig = INGRESO_A; //cuando llega el primer numero
                    INGRESO_A: if (confirmar_a) estado_sig = INGRESO_B;//cuando el usuario confirma A
                    INGRESO_B: if (ejecutar) begin//cuando pide ejecutar
                        estado_sig       = RESULTADO;
                        suma_valida_next = 1'b1;//actia el sumador
                    end
                    RESULTADO: ;
                    default: estado_sig = IDLE;//FSM vuelve a IDLE
                endcase
            end
        end
    end
 
    assign operando_a = reg_a;//conecta la salida operando_a al registro interno re_a de modo que cualquier cambio en reg_a aparace en la salida
    assign operando_b = reg_b;//lo mismo para las demas 
    assign estado_dbg = estado;
 
endmodule
