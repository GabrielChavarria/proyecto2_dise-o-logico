# Diagrama General del Sistema

## Diagrama de bloques completo

```
Teclado físico (4x4)
        │
        ▼
┌─────────────────────────────────────────────────────┐
│              Subsistema 1 — Teclado                 │
│                                                     │
│  [sincronizador] → [debounce x4] → [barrido]       │
│                                        │            │
│                              [decodificador_tecla]  │
│                                        │            │
│                              [fsm_entrada_datos]    │
└────────────────────────────────────────┬────────────┘
                                         │ operando_a, operando_b
                                         ▼
                        ┌────────────────────────┐
                        │  Subsistema 2 — Suma   │
                        │       [sumador]        │
                        └────────────┬───────────┘
                                     │ resultado [10:0]
                                     ▼
                  ┌──────────────────────────────────────┐
                  │       Subsistema 3 — Display         │
                  │                                      │
                  │  [divisor_frecuencia] → pulso 1kHz   │
                  │                                      │
                  │  resultado → BCD → [controlador]     │
                  │                    instancia         │
                  │               [decodificador_7seg]   │
                  └──────────────────┬───────────────────┘
                                     │
                           segmentos + ánodos
                                     │
                                     ▼
                           Display físico 4 dígitos
```

## Ruta de datos

| Etapa | Señal | Bits |
|---|---|---|
| Entrada teclado | `in_col[3:0]` | 4 |
| Después sincronizador | `cols_sync[3:0]` | 4 |
| Después debounce | `cols_db[3:0]` | 4 |
| Tecla detectada | `fila_cap + col_cap` | 4+4 |
| Dígito decodificado | `digito[3:0]` | 4 |
| Operando A | `operando_a[9:0]` | 10 |
| Operando B | `operando_b[9:0]` | 10 |
| Resultado | `resultado[10:0]` | 11 |
| BCD para display | `numero_bcd[15:0]` | 16 |
| Segmentos | `segmentos_out[6:0]` | 7 |
| Ánodos | `anodos_out[3:0]` | 4 |
