# 3.1 Módulo: sumador.sv

## Función
Calcula la suma sin signo de dos operandos de 10 bits cuando recibe la señal de habilitación, produciendo un resultado de 11 bits.

## Puertos

| Puerto | Dirección | Bits | Descripción |
|---|---|---|---|
| `clk` | input | 1 | Reloj 27 MHz |
| `rst_n` | input | 1 | Reset activo en bajo |
| `operando_a[9:0]` | input | 10 | Primer operando (0-999) |
| `operando_b[9:0]` | input | 10 | Segundo operando (0-999) |
| `suma_valida` | input | 1 | Pulso de habilitación |
| `resultado[10:0]` | output | 11 | Suma de los operandos (0-1998) |

## Descripción de funcionamiento
El módulo es un registro que se actualiza en el flanco de reloj cuando `suma_valida` está en alto. En ese momento calcula y almacena `operando_a + operando_b`. El resultado se mantiene hasta el siguiente reset o nueva suma.

## Ejemplo

| operando_a | operando_b | resultado |
|---|---|---|
| 123 | 456 | 579 |
| 999 | 999 | 1998 |
| 0 | 0 | 0 |

## Código fuente
Ver [sumador.sv](../src/design/sumador.sv)
