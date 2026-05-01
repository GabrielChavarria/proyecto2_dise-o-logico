# Proyecto corto II — Diseño digital sincrónico en HDL

## Escuela de Ingeniería Electrónica
**Curso:** EL-3307 Diseño Lógico  

**Semestre:** I Semestre 2026  

**Profesor:** Oscar Caravaca

---
## Integrantes
- Gabriel Alonso Chavarría Rodriguez
- Alberto Javier Arce Estrada

---
## Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays
- **HDL**: Hardware Description Language
---
## Herramientas Utilizadas
- **Descripción Hardware**: SystemVerilog
---
## Referencias
- [1] [Open Source FPGA Environment](https://github.com/DJosueMM/open_source_fpga_environment/wiki)
- [2] [TangNano 9K Wiki](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html)

---
## Objetivo
Diseñar e implementar un sistema digital sincrónico en una FPGA Tang Nano 9k que capture dos números enteros positivos de hasta tres dígitos decimales cada uno desde un teclado hexadecimal, calcule su suma sin signo y despliegue los valores ingresados y el resultado en cuatro dispositivos de 7 segmentos, operando a una frecuencia de reloj de 27 MHz.

---
## Descripción General

El presente proyecto implementa una calculadora de suma de dos números de hasta tres dígitos decimales utilizando una FPGA Tang Nano 9k como plataforma de desarrollo. El sistema se divide en tres subsistemas principales: lectura del teclado hexadecimal, suma aritmética y despliegue en displays de 7 segmentos.

El subsistema de lectura del teclado captura las pulsaciones del usuario mediante un algoritmo de barrido fila-columna, eliminando el rebote mecánico y sincronizando las señales al dominio del reloj interno de 27 MHz. Una máquina de estados finitos (FSM) controla el flujo de ingreso de datos, permitiendo ingresar el primer operando, confirmar con la tecla A, ingresar el segundo operando y ejecutar la suma con la tecla B. El resultado se convierte a formato BCD y se despliega en tiempo real en el display de 4 dígitos mediante multiplexeo a 1 kHz.

---
## Estructura del Proyecto

```text
proyecto2_diseño-logico
├── docs
│   ├── Instrucciones_Proyecto_2.pdf
│   ├── Datasheet_displayRojo.pdf
│   ├── DataSheet_Teclado.pdf
│   └── FPGA_pinmap.png
├── src
│   ├── build
│   │   └── Makefile
│   ├── constr
│   │   └── constraints.cst
│   ├── design
│   │   ├── top.sv
│   │   ├── divisor_frecuencia.sv
│   │   ├── sincronizador.sv
│   │   ├── debounce.sv
│   │   ├── barrido_teclado.sv
│   │   ├── decodificador_tecla.sv
│   │   ├── fsm_entrada_datos.sv
│   │   ├── sumador.sv
│   │   ├── controlador_displays.sv
│   │   └── decodificador_7seg.sv
│   └── sim
│       ├── tb_display.sv
│       └── tb_debounce.sv
├── .gitignore
└── README.md
```

---
## Subsistemas

### Subsistema 1 — Lectura del teclado hexadecimal
Captura, elimina rebote y sincroniza las pulsaciones del teclado 4x4 al reloj de 27 MHz. Implementa una FSM que controla el ingreso de los dos operandos.

**Módulos:**
- `sincronizador.sv` — Sincroniza señales externas al dominio del reloj (2 FF en cascada)
- `debounce.sv` — Elimina rebotes mecánicos (20ms de estabilidad requerida)
- `barrido_teclado.sv` — Escanea filas y lee columnas detectando teclas presionadas
- `decodificador_tecla.sv` — Convierte par fila-columna al dígito decimal correspondiente
- `fsm_entrada_datos.sv` — Controla el flujo: ingreso A → confirmación → ingreso B → suma

### Subsistema 2 — Suma aritmética
Recibe los dos operandos almacenados y calcula su suma sin signo.

**Módulos:**
- `sumador.sv` — Suma dos operandos de 10 bits, resultado de 11 bits

### Subsistema 3 — Despliegue en 7 segmentos
Convierte el resultado a BCD y lo despliega en 4 dígitos mediante multiplexeo.

**Módulos:**
- `divisor_frecuencia.sv` — Genera pulso de habilitación a 1 kHz desde 27 MHz
- `decodificador_7seg.sv` — Convierte dígito BCD (0-9) a señales de segmentos
- `controlador_displays.sv` — Multiplexa los 4 dígitos activando un cátodo a la vez

---
## Uso de la Calculadora

| Acción | Tecla |
|---|---|
| Ingresar dígitos del primer número | 0-9 |
| Confirmar primer número | A |
| Ingresar dígitos del segundo número | 0-9 |
| Ejecutar suma | B |
| Limpiar y reiniciar | D |

**Máximo:** 3 dígitos por operando (0-999). Resultado máximo: 1998.

---
## Constraints — Asignación de Pines

### Display 5643AS-1 (cátodo común)
| Señal | Pin FPGA | Pin Display | Descripción |
|---|---|---|---|
| anodos_out[0] | 37 | 12 | Ánodo dígito 1 |
| anodos_out[1] | 26 | 9 | Ánodo dígito 2 |
| anodos_out[2] | 27 | 8 | Ánodo dígito 3 |
| anodos_out[3] | 34 | 6 | Ánodo dígito 4 |
| segmentos_out[0] | 36 | 11 | Segmento a |
| segmentos_out[1] | 25 | 7 | Segmento b |
| segmentos_out[2] | 30 | 4 | Segmento c |
| segmentos_out[3] | 29 | 2 | Segmento d |
| segmentos_out[4] | 28 | 1 | Segmento e |
| segmentos_out[5] | 39 | 10 | Segmento f |
| segmentos_out[6] | 33 | 5 | Segmento g |

### Teclado Grayhill 96BB2 (4x4)
| Señal | Pin FPGA | Terminal | Descripción |
|---|---|---|---|
| out_fil[0] | 51 | 1 | Fila 1 (1,2,3,A) |
| out_fil[1] | 53 | 2 | Fila 2 (4,5,6,B) |
| out_fil[2] | 54 | 3 | Fila 3 (7,8,9,C) |
| out_fil[3] | 55 | 4 | Fila 4 (*,0,#,D) |
| in_col[0] | 56 | 5 | Columna 1 (1,4,7,*) |
| in_col[1] | 57 | 6 | Columna 2 (2,5,8,0) |
| in_col[2] | 68 | 7 | Columna 3 (3,6,9,#) |
| in_col[3] | 69 | 8 | Columna 4 (A,B,C,D) |

