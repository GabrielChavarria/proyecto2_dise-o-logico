module top (
    input  logic        clk_27mhz,     // entrada de la señal de relog del sistema de 27Mhz, todo el diseño se sincriniza con esta señál
    input  logic        reset_n,       // entrada reset en bajo, si es igual a 0 el sistema se reinicia  

    // Teclado matricial de 4 columnas 
    input  logic [3:0]  in_col,        // columnas (en modo pull-up , reposo en estado 1111)
    output logic [3:0]  out_fil,       // filas (una activa en bajo a la vez para realizar el barrido/escaneo )

    // Display (catodo comun)
    output logic [7:0]  segmentos_out, // segmentos del display ejem [0]=a ... [6]=g, [7]=dp
    output logic [3:0]  anodos_out     // senal a los digitos del display  anodos_out[0]=D1 ... [3]=D4, activo en bajo
);

    // Reset interno al encender
    logic        rst_n_int; //  reset interno
    logic [3:0]  rst_cnt = 4'd0;// contador de 4 bits

// este bloque egenra un delay corto para esperar a que la señal de relog se estabilice, como tenemos un registro de 4 bits, tardara 15 ciclos en terminar
    always_ff @(posedge clk_27mhz) begin//always_ff se activa en cada flanco positivo del relog,
        if (!(&rst_cnt)) // revisa si todos los bits del rst_cnt son 1
            rst_cnt <= rst_cnt + 1;// incrementa el contador cada ciclo 
    end
    assign rst_n_int = (&rst_cnt) & reset_n;// otro reset interno cuando termina el cntador 

    // Señales internas
    logic [3:0] cols_sync;//columnas del teclado ya sincronizadas
    logic       pulso_tick;// un pulso lento de alrededopr de 1kHz
    logic [3:0] fila_cap;//estos dos fila_cap y col_cap indican que tecla se presionio
    logic [3:0] col_cap;// 
    logic       tecla_valida;//pulso de un ciclo, indica que se detecto una nueva tecla valida 

    logic [3:0] digito;// guarda el valor numerido de la tecla, de 0 a 9
    logic       es_numero;// 1 si la tecla es un numero
    //señales de control
    logic       confirmar_a;// la tecla A sera el +
    logic       ejecutar;// la tecla B sera el =
    logic       limpiar;// la tecla D el reset
// datos que recibe la calculadora 
    logic [9:0]  operando_a;//
    logic [9:0]  operando_b;//



    logic        suma_valida;// iondica que ya se tiene los datos para hacer la suma
    logic [1:0]  estado_dbg;//estado actual de la FSM
    logic [10:0] resultado;// resultado de la suma

    logic [10:0] num_display;//Numero que se va a mostrar (puede ser A, B o el resultado)
    //separacion de las unidades, decenas, centenas , millares, para el display
    logic [3:0]  d_miles;
    logic [3:0]  d_cientos;
    logic [3:0]  d_decenas;
    logic [3:0]  d_unidades;
    logic [15:0] numero_bcd;
    logic [6:0]  segs_internos;

    // Sincronizador de columnas
    sincronizador #(.BITS(4)) sync_cols (// instancia un modulo sincronizador de 4 bits 
        .clk         (clk_27mhz),
        .senal_async (in_col),
        .senal_sync  (cols_sync)
    );

    // Divisor de frecuencia 27MHz -> 1kHz
    divisor_frecuencia #(.N(27000)) div_tick (
        .clk   (clk_27mhz),
        .rst_n (rst_n_int),
        .pulso (pulso_tick)
    );

    // Barrido del teclado
    // hace un escaneo secuancial de las filas del teclado matricial 
    
    barrido_teclado barrido (
        .clk          (clk_27mhz),// relog 
        .rst_n        (rst_n_int),//reset interno, activo en bajo
        .pulso        (pulso_tick),//un pulso mas lento para el barrido y debounce
        .cols_sync    (cols_sync),//columnas ya sincronozadas
        .filas        (out_fil),//filas, se ativan secuancialmente 
        .fila_cap     (fila_cap),// fila de la tecla presionada
        .col_cap      (col_cap),//columan de la tecla presionada
        .tecla_valida (tecla_valida)//señal que indica que la tecla es valida 
    );

    // Decodificador de tecla
    //converte la combinacion fila+columna en un digito numerico
    decodificador_tecla deco_tecla (
        .fila_cap    (fila_cap),// fila de la tecla presionada 
        .col_cap     (col_cap),//// columna de la tecla presionada
        .digito      (digito),//valor numerico decodificado
        .es_numero   (es_numero)//indica si la tecla es un numero
        .confirmar_a (confirmar_a)// se activa cuando detecta que se presiono la tecla A

        .ejecutar    (ejecutar),// ejecuta la suma, cuando detecta que se presiono la tecla B
        .limpiar     (limpiar)// al detectar que se presiono la tecla  D, reinicia la calculadora
    );

    // FSM de entrada de datos
    //esta parte controla el flujo de la calculadora
    // 1. Ingreso del operando A
    // 2. Confirmación del operando A
    // 3. Ingreso del operando B
    // 4. Ejecución de la suma
    fsm_entrada_datos fsm (
        .clk          (clk_27mhz),//relog del sistema
        .rst_n        (rst_n_int),//reset interno 


        .tecla_valida (tecla_valida),//indica que se detecto una nueva tecla
        .digito       (digito),// numero de la tecla
        .es_numero    (es_numero),// dice si la tecla es un numero
        .confirmar_a  (confirmar_a),// confirma que ingreso el comando A (+)
        .ejecutar     (ejecutar),// ejecuta la operacion
        .limpiar      (limpiar),//reinicia el sistema
//salida de datos
        .operando_a   (operando_a),//primer operando
        .operando_b   (operando_b),//segundo operando
        .suma_valida  (suma_valida),//señar de control para activar el sumador
        .estado_dbg   (estado_dbg)//estado de la FSM
    );

    // Sumador
    sumador sum (
        .clk         (clk_27mhz),
        .rst_n       (rst_n_int),
        .operando_a  (operando_a),
        .operando_b  (operando_b),
        .suma_valida (suma_valida),
        .resultado   (resultado)
    );

    // Conversion binario a BCD para el display
    //dependiendo de lo que indique la FSM se mostrara en el display
     //  - Estado 0: mostrar operando A
     //  - Estado 1: mostrar operando B
     //  - Estado 2: mostrar resultado
    
    always_comb begin
        case (estado_dbg)
            2'd0:    num_display = {1'b0, operando_a}; // extender a 11 bits
            2'd1:    num_display = {1'b0, operando_b};// extender a 11 bits
            2'd2:    num_display = resultado;//ver suma
            default: num_display = 11'd0;// valor por default
        endcase
//conversion de binario a decimal 
        d_miles    =  num_display / 11'd1000;
        d_cientos  = (num_display % 11'd1000) / 11'd100;
        d_decenas  = (num_display % 11'd100)  / 11'd10;
        d_unidades =  num_display % 11'd10;
    end
//guarda los 4 digitos deciales en formato BCD(Binary coded decimal/decimal codificado en binario) 
    assign numero_bcd = {d_miles, d_cientos, d_decenas, d_unidades};

    // Controlador del display
    controlador_displays ctrl_disp (
        .clk       (clk_27mhz),
        .rst_n     (rst_n_int),
        .pulso     (pulso_tick),
        .numero    (numero_bcd),
        .segmentos (segs_internos),
        .anodos    (anodos_out)
    );
// Mapeo de señales internas hacia las salidas físicas del display
// Conexion segmentos {a,b,c,d,e,f,g}
    assign segmentos_out[0] = segs_internos[0]; // a
    assign segmentos_out[1] = segs_internos[1]; // b
    assign segmentos_out[2] = segs_internos[2]; // c
    assign segmentos_out[3] = segs_internos[3]; // d
    assign segmentos_out[4] = segs_internos[4]; // e
    assign segmentos_out[5] = segs_internos[5]; // f
    assign segmentos_out[6] = segs_internos[6]; // g
    assign segmentos_out[7] = 1'b0;             // dp apagado

endmodule
