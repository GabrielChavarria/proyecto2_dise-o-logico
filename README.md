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

## 1. Introducción

El presente proyecto implementa una calculadora de suma sobre una FPGA Tang Nano 9k utilizando SystemVerilog como lenguaje de descripción de hardware. El sistema captura dos números enteros positivos de hasta tres dígitos decimales desde un teclado hexadecimal físico, calcula su suma sin signo y despliega los valores ingresados y el resultado en un display de 4 dígitos de 7 segmentos. Todo el diseño opera bajo los principios del diseño digital sincrónico, empleando un único reloj de 27 MHz y divisores de frecuencia para los subsistemas que requieren operación más lenta.

---

## 2. Definición del Problema, Objetivos y Especificaciones

### Problema
Se requiere diseñar un circuito digital sincrónico capaz de capturar dos números enteros positivos de al menos tres dígitos decimales desde un teclado hexadecimal mecánico, calcular su suma sin signo y desplegarla en cuatro dispositivos de 7 segmentos.

### Objetivos
- Implementar un algoritmo de captura de datos desde un teclado hexadecimal con eliminación de rebote
- Diseñar una FSM que controle el ingreso secuencial de dos operandos
- Implementar la suma aritmética de los operandos
- Desplegar los números y el resultado en displays de 7 segmentos mediante multiplexeo
- Verificar el diseño mediante simulaciones RTL (pre-síntesis)

### Especificaciones
- Frecuencia de reloj: **27 MHz** (oscilador interno TangNano 9k)
- Un solo dominio de reloj en todo el sistema
- Dos números de hasta **3 dígitos decimales** cada uno (0-999)
- Resultado máximo: **1998** (4 dígitos)
- Display: 4 dígitos de 7 segmentos, cátodo común, multiplexeo a 1 kHz
- Teclado: hexadecimal 4x4, barrido fila-columna

---

## 3. Descripción General del Sistema

El sistema se divide en tres subsistemas interconectados que operan sincrónicamente bajo el reloj de 27 MHz:

```
```mermaid
flowchart TD

A[Teclado físico] --> B[Subsistema 1: Lectura del teclado]

B --> C[Sincronizador]
C --> D[Debounce]
D --> E[Barrido]
E --> F[Decodificador]
F --> G[FSM]

G -->|operando_a, operando_b| H[Subsistema 2: Suma]
H --> I[Sumador]

I -->|resultado| J[Subsistema 3: Display]
J --> K[Divisor de frecuencia]
K --> L[Controlador de displays]

L -->|segmentos + ánodos| M[Display físico]

### Subsistema 1 — Lectura del teclado
Captura y procesa las pulsaciones del teclado 4x4. Las señales físicas pasan por un sincronizador de 2 flip-flops para eliminar metaestabilidad, luego por un módulo de debounce que requiere 20ms de señal estable. El módulo de barrido escanea las 4 filas secuencialmente y detecta qué columna responde. El decodificador convierte el par fila-columna al dígito correspondiente. La FSM controla el flujo: ingreso del primer número → confirmación con A → ingreso del segundo número → ejecución de suma con B.

### Subsistema 2 — Suma aritmética
Recibe los dos operandos de 10 bits almacenados por la FSM y calcula su suma sin signo, produciendo un resultado de 11 bits que puede representar hasta 1998.

### Subsistema 3 — Display de 7 segmentos
El divisor de frecuencia genera un pulso de habilitación a 1 kHz. El controlador de displays multiplexa los 4 dígitos activando un cátodo a la vez en ciclos de 1ms. Internamente instancia el decodificador BCD que convierte cada dígito decimal a las señales de los segmentos correspondientes.

---

## 4. Diagramas de Bloques

### Diagrama general del sistema
Ver [wiki: Diagrama General](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Diagrama-General)

### Subsistema 1 — Teclado
Ver [wiki: Subsistema Teclado](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Subsistema-Teclado)

**Módulos:**
| Módulo | Wiki |
|---|---|
| `sincronizador.sv` | [Módulo Sincronizador](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Modulo-sincronizador) |
| `debounce.sv` | [Módulo Debounce](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Modulo-debounce) |
| `barrido_teclado.sv` | [Módulo Barrido Teclado](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Modulo-barrido-teclado) |
| `decodificador_tecla.sv` | [Módulo Decodificador Tecla](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Modulo-decodificador-tecla) |
| `fsm_entrada_datos.sv` | [Módulo FSM Entrada Datos](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Modulo-FSM-entrada-datos) |

### Subsistema 2 — Suma
Ver [wiki: Subsistema Suma](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Subsistema-Suma)

**Módulos:**
| Módulo | Wiki |
|---|---|
| `sumador.sv` | [Módulo Sumador](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Modulo-sumador) |

### Subsistema 3 — Display
Ver [wiki: Subsistema Display](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Subsistema-Display)

**Módulos:**
| Módulo | Wiki |
|---|---|
| `divisor_frecuencia.sv` | [Módulo Divisor Frecuencia](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Modulo-divisor-frecuencia) |
| `decodificador_7seg.sv` | [Módulo Decodificador 7seg](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Modulo-decodificador-7seg) |
| `controlador_displays.sv` | [Módulo Controlador Displays](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Modulo-controlador-displays) |

---

## 5. Diagramas de Estado de las FSM

### FSM de entrada de datos (`fsm_entrada_datos.sv`)
Ver [wiki: FSM Entrada Datos](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Modulo-FSM-entrada-datos)

```
         [IDLE]
            │ es_numero
            ▼
        [INGRESO_A] ──────── limpiar ──► [IDLE]
            │ confirmar_a (tecla A)
            ▼
        [INGRESO_B] ──────── limpiar ──► [IDLE]
            │ ejecutar (tecla B)
            ▼
        [RESULTADO] ──────── limpiar ──► [IDLE]
```

| Estado | Display muestra | Acción |
|---|---|---|
| IDLE | `0000` | Esperando primer dígito |
| INGRESO_A | operando_a | Ingresando primer número |
| INGRESO_B | operando_b | Ingresando segundo número |
| RESULTADO | resultado | Mostrando suma |

---

## 6. Simulación Funcional

### Simulación del display (`tb_display.sv`)
Ver [wiki: Simulación Display](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Simulacion-Display)

La simulación verifica el correcto funcionamiento del multiplexeo mostrando el número hardcodeado `1234`:

```
t=0    | anodos=1110 | segmentos=0000110 | digito=1
t=1ms  | anodos=1101 | segmentos=1011011 | digito=2
t=2ms  | anodos=1011 | segmentos=1001111 | digito=3
t=3ms  | anodos=0111 | segmentos=1100110 | digito=4
```

### Simulación del debounce (`tb_debounce.sv`)
Ver [wiki: Simulación Debounce](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Simulacion-Debounce)

La simulación verifica que el módulo ignora rebotes de 2ms y solo acepta la señal después de 20ms estables:

```
--- Prueba 1: tecla presionada con rebote ---
senal_out antes: 1
t=38ms | senal_out despues de estabilizar: 0

--- Prueba 2: tecla soltada con rebote ---
t=89ms | senal_out al soltar: 1
```

---

## 7. Análisis de Recursos FPGA

Ver [wiki: Recursos FPGA](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Recursos-FPGA)

*(Datos obtenidos de los logs de síntesis y PnR)*

| Recurso | Cantidad utilizada |
|---|---|
| LUT4 | — |
| DFF | — |
| Pines IO | 23 |

---

## 8. Reporte de Velocidad Máxima de Reloj

Ver [wiki: Timing](https://github.com/GabrielChavarria/proyecto2_dise-o-logico/wiki/Timing)

*(Datos obtenidos del log de PnR `pnr_tangnano9k.log`)*

| Parámetro | Valor |
|---|---|
| Frecuencia de operación | 27 MHz |
| Frecuencia máxima reportada | — |

---

## 9. Análisis de Problemas y Soluciones

| Problema | Solución |
|---|---|
| Display con lógica activo-alto incorrecta para cátodo común | Se invirtió la lógica de los ánodos en `controlador_displays.sv` a activo-bajo |
| Tecla registrada múltiples veces al mantener presionada | Se implementó `release_cnt` en `barrido_teclado.sv` requiriendo 25 pulsos estables para confirmar liberación |
| Lectura intermitente del teclado | Se redujo `TICKS` del debounce de 40ms a 20ms para dar mayor margen dentro del ciclo de barrido |
| Conflicto de bancos de voltaje en gowin_pack | Se declaró `reset_n` en pin 88 en el `.cst` para resolver el conflicto de banco IOT/IOB |
| Pines 68 y 69 en banco IOT (1.8V) | Se verificó compatibilidad como entradas con señales de 3.3V del teclado |

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

### Teclado
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
