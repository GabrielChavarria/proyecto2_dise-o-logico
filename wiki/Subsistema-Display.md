# 4. Subsistema 3 — Display de 7 Segmentos

## Descripción
Convierte el número a mostrar en formato BCD y lo despliega en el display de 4 dígitos mediante multiplexeo a 1 kHz.

## Diagrama de bloques

```
num_display[10:0]
        │
        ▼
   [división BCD]
   d_miles, d_cientos, d_decenas, d_unidades
        │
        ▼ numero_bcd[15:0]
┌───────────────────────────────────────┐
│       controlador_displays            │
│                                       │
│  [divisor_frecuencia] → pulso 1kHz   │
│                                       │
│  [contador digito_activo 0-3]        │
│          │                           │
│   ┌──────┴──────┐                   │
│   │             │                   │
│ anodos_out   [decodificador_7seg]   │
│ (activo bajo) segmentos_out         │
└───────────────────────────────────────┘
```

## Módulos
- [Divisor Frecuencia](Modulo-divisor-frecuencia)
- [Decodificador 7seg](Modulo-decodificador-7seg)
- [Controlador Displays](Modulo-controlador-displays)

## Conexión física — Display 5643AS-1

| Pin FPGA | Pin Display | Señal | Resistencia |
|---|---|---|---|
| 37 | 12 | Ánodo D1 | No |
| 26 | 9 | Ánodo D2 | No |
| 27 | 8 | Ánodo D3 | No |
| 34 | 6 | Ánodo D4 | No |
| 36 | 11 | Segmento a | 150Ω |
| 25 | 7 | Segmento b | 150Ω |
| 30 | 4 | Segmento c | 150Ω |
| 29 | 2 | Segmento d | 150Ω |
| 28 | 1 | Segmento e | 150Ω |
| 39 | 10 | Segmento f | 150Ω |
| 33 | 5 | Segmento g | 150Ω |
