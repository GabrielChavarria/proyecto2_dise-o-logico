# 2.1 Módulo: sincronizador.sv

## Función
Sincroniza señales externas del teclado al dominio del reloj interno de 27 MHz, eliminando la metaestabilidad mediante dos flip-flops en cascada.

## Puertos

| Puerto | Dirección | Bits | Descripción |
|---|---|---|---|
| `clk` | input | 1 | Reloj 27 MHz |
| `senal_async[BITS-1:0]` | input | 4 | Señales externas sin sincronizar |
| `senal_sync[BITS-1:0]` | output | 4 | Señales sincronizadas |

## Parámetros

| Parámetro | Valor | Descripción |
|---|---|---|
| `BITS` | 4 | Número de señales a sincronizar |

## Diagrama de bloques

```
senal_async ──► [FF1] ──► [FF2] ──► senal_sync
               puede      estable
            metaestable
```

## Descripción de funcionamiento
Las señales del teclado cambian en cualquier momento sin respetar el reloj de la FPGA. Si una señal cambia exactamente en el flanco del reloj, el flip-flop puede quedar en un estado indefinido (metaestabilidad). El primer flip-flop puede quedar metaestable, pero tiene 37ns (un ciclo de 27 MHz) para estabilizarse. El segundo flip-flop lee la señal ya estabilizada.

## Código fuente
Ver [sincronizador.sv](../src/design/sincronizador.sv)
