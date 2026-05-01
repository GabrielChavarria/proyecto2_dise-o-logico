# Módulo: debounce.sv

## Función
Elimina el rebote mecánico de las teclas del teclado. Solo acepta un cambio de señal si se mantiene estable durante 20ms consecutivos.

## Puertos

| Puerto | Dirección | Bits | Descripción |
|---|---|---|---|
| `clk` | input | 1 | Reloj 27 MHz |
| `rst_n` | input | 1 | Reset activo en bajo |
| `pulso` | input | 1 | Enable 1 kHz del divisor de frecuencia |
| `senal_in` | input | 1 | Señal sincronizada del teclado |
| `senal_out` | output | 1 | Señal limpia sin rebote |

## Parámetros

| Parámetro | Valor | Descripción |
|---|---|---|
| `TICKS` | 20 | Ciclos de 1 kHz requeridos (20 ms) |

## Diagrama de bloques

```
senal_in: 1─┐0┐1┐0┐1┐0────────────────
             rebotes    estable 20ms
contador:  0►reset►reset►0,1,2...19
senal_out: 1────────────────────────0
                                    ↑
                              acepta aquí
```

## Descripción de funcionamiento
Cuando la señal cambia, un contador empieza a contar pulsos de 1 kHz. Si la señal vuelve al valor anterior antes de llegar a TICKS (rebote), el contador se reinicia. Solo cuando la señal se mantiene estable durante TICKS pulsos (20 ms) se acepta el cambio y se actualiza la salida.

## Código fuente
Ver [debounce.sv](../src/design/debounce.sv)
