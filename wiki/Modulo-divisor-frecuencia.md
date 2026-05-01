# 4.1 Módulo: divisor_frecuencia.sv

## Función
Divide el reloj de 27 MHz generando un pulso de habilitación a 1 kHz que usan los subsistemas de teclado y display.

## Puertos

| Puerto | Dirección | Bits | Descripción |
|---|---|---|---|
| `clk` | input | 1 | Reloj 27 MHz |
| `rst_n` | input | 1 | Reset activo en bajo |
| `pulso` | output | 1 | Pulso de 1 ciclo cada 1 ms |

## Parámetros

| Parámetro | Valor | Descripción |
|---|---|---|
| `N` | 27000 | 27 MHz / 27000 = 1 kHz |

## Diagrama de bloques

```
clk (27MHz) ──► [contador hasta N-1] ──► pulso (1kHz)
rst_n ─────────────────────────────────►
```

## Funcionamiento
Cuenta desde 0 hasta N-1. Cuando llega a N-1 genera un pulso de 1 ciclo y reinicia el contador. El pulso dura exactamente un ciclo de reloj (37 ns).

## Código fuente
Ver [divisor_frecuencia.sv](../src/design/divisor_frecuencia.sv)
