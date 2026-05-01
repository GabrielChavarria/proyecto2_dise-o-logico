# 5.1 Simulación del Display

## Testbench: `tb_display.sv`

### Objetivo
Verificar el correcto funcionamiento del multiplexeo del display mostrando el número hardcodeado `1234`.

### Configuración
- Reloj: 27 MHz (periodo 37 ns)
- Número de prueba: `{4'd1, 4'd2, 4'd3, 4'd4}` = 1234
- Duración: 120,000 ciclos (~4.4 ms)

### Resultados obtenidos

```
t=0        | anodos=1111 | segmentos=0000000 | digito=? (reset)
t=0        | anodos=1110 | segmentos=0000110 | digito=1
t=1026171  | anodos=1101 | segmentos=1011011 | digito=2
t=2052171  | anodos=1011 | segmentos=1001111 | digito=3
t=3078171  | anodos=0111 | segmentos=1100110 | digito=4
t=4104171  | anodos=1110 | segmentos=0000110 | digito=1 (ciclo repite)
```

### Análisis
- El ciclo completo de 4 dígitos tarda ~4ms ✓
- Cada dígito está activo exactamente 1ms ✓
- Los ánodos son activo bajo (cátodo común) ✓
- Los segmentos muestran los valores correctos ✓
- El multiplexeo es correcto y continuo ✓
