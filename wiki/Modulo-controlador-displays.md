# Módulo: controlador_displays.sv

## Función
Multiplexa los 4 dígitos del display activando un cátodo a la vez cada 1 ms, creando la ilusión de que todos los dígitos están encendidos simultáneamente.

## Puertos

| Puerto | Dirección | Bits | Descripción |
|---|---|---|---|
| `clk` | input | 1 | Reloj 27 MHz |
| `rst_n` | input | 1 | Reset activo en bajo |
| `pulso` | input | 1 | Enable 1 kHz |
| `numero[15:0]` | input | 16 | 4 dígitos BCD empacados |
| `segmentos[6:0]` | output | 7 | Señales de segmentos |
| `anodos[3:0]` | output | 4 | Control de dígitos (activo bajo) |

## Formato de entrada `numero[15:0]`

```
numero = {miles, centenas, decenas, unidades}
       = {4 bits, 4 bits,  4 bits,  4 bits }
Ejemplo 1234: numero = {4'd1, 4'd2, 4'd3, 4'd4} = 16'h1234
```

## Patrón de multiplexeo (activo bajo)

| digito_activo | anodos | Dígito encendido |
|---|---|---|
| 0 | 1110 | D1 (izquierda) |
| 1 | 1101 | D2 |
| 2 | 1011 | D3 |
| 3 | 0111 | D4 (derecha) |

## Diagrama temporal

```
Tiempo:  0ms    1ms    2ms    3ms    4ms
anodos: 1110   1101   1011   0111   1110 ...
        D1     D2     D3     D4     D1
```

## Código fuente
Ver [controlador_displays.sv](../src/design/controlador_displays.sv)
