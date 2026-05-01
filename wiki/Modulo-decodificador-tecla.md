# Módulo: decodificador_tecla.sv

## Función
Convierte el par fila-columna capturado por el barrido al dígito decimal correspondiente y genera señales de control para la FSM.

## Puertos

| Puerto | Dirección | Bits | Descripción |
|---|---|---|---|
| `fila_cap[3:0]` | input | 4 | Fila capturada (one-hot activo bajo) |
| `col_cap[3:0]` | input | 4 | Columna capturada (one-hot activo bajo) |
| `digito[3:0]` | output | 4 | Dígito decimal (0-9) |
| `es_numero` | output | 1 | 1 si la tecla es un dígito numérico |
| `confirmar_a` | output | 1 | 1 si se presionó A (+) |
| `ejecutar` | output | 1 | 1 si se presionó B (=) |
| `limpiar` | output | 1 | 1 si se presionó D (reset) |

## Tabla de decodificación

| Tecla | fila_cap | col_cap | digito | Señal activa |
|---|---|---|---|---|
| 1 | 1110 | 1110 | 1 | es_numero |
| 2 | 1110 | 1101 | 2 | es_numero |
| 3 | 1110 | 1011 | 3 | es_numero |
| A | 1110 | 0111 | — | confirmar_a |
| 4 | 1101 | 1110 | 4 | es_numero |
| 5 | 1101 | 1101 | 5 | es_numero |
| 6 | 1101 | 1011 | 6 | es_numero |
| B | 1101 | 0111 | — | ejecutar |
| 7 | 1011 | 1110 | 7 | es_numero |
| 8 | 1011 | 1101 | 8 | es_numero |
| 9 | 1011 | 1011 | 9 | es_numero |
| 0 | 0111 | 1101 | 0 | es_numero |
| D | 0111 | 0111 | — | limpiar |

## Código fuente
Ver [decodificador_tecla.sv](../src/design/decodificador_tecla.sv)
