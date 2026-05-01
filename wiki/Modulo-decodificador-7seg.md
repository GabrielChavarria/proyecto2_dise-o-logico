# Módulo: decodificador_7seg.sv

## Función
Convierte un dígito BCD (0-9) a las señales de los 7 segmentos del display. Lógica combinacional pura, sin reloj.

## Puertos

| Puerto | Dirección | Bits | Descripción |
|---|---|---|---|
| `bcd[3:0]` | input | 4 | Dígito decimal (0-9) |
| `segmentos[6:0]` | output | 7 | Señales de segmentos {g,f,e,d,c,b,a} |

## Distribución física de segmentos

```
 _
|_|   a = arriba
|_|   b = derecha arriba
      c = derecha abajo
      d = abajo
      e = izquierda abajo
      f = izquierda arriba
      g = medio
```

## Tabla de conversión (cátodo común, activo alto)

| Dígito | g | f | e | d | c | b | a | Binario |
|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 1 | 1 | 1 | 1 | 1 | 1 | 0111111 |
| 1 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 0000110 |
| 2 | 1 | 0 | 1 | 1 | 0 | 1 | 1 | 1011011 |
| 3 | 1 | 0 | 0 | 1 | 1 | 1 | 1 | 1001111 |
| 4 | 1 | 1 | 0 | 0 | 1 | 1 | 0 | 1100110 |
| 5 | 1 | 1 | 0 | 1 | 1 | 0 | 1 | 1101101 |
| 6 | 1 | 1 | 1 | 1 | 1 | 0 | 1 | 1111101 |
| 7 | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 0000111 |
| 8 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1111111 |
| 9 | 1 | 1 | 0 | 1 | 1 | 1 | 1 | 1101111 |

## Código fuente
Ver [decodificador_7seg.sv](../src/design/decodificador_7seg.sv)
