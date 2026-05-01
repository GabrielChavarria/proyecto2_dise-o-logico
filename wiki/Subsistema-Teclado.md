# Subsistema 1 — Lectura del Teclado Hexadecimal

## Descripción
Captura, sincroniza y decodifica las pulsaciones del teclado 4x4. Implementa una FSM que controla el ingreso secuencial de dos operandos.

## Diagrama de bloques

```
in_col[3:0] (físico)
        │
        ▼
┌──────────────────┐
│  sincronizador   │  2 FF en cascada, elimina metaestabilidad
└────────┬─────────┘
         │ cols_sync[3:0]
         ▼
┌──────────────────┐
│  debounce x4     │  20ms de señal estable requerida
└────────┬─────────┘
         │ cols_db[3:0]
         ▼
┌──────────────────┐      out_fil[3:0]
│ barrido_teclado  │ ──────────────────► filas del teclado
└────────┬─────────┘
         │ fila_cap, col_cap, tecla_valida
         ▼
┌──────────────────────┐
│ decodificador_tecla  │
└──────────┬───────────┘
           │ digito, es_numero, confirmar_a, ejecutar, limpiar
           ▼
┌──────────────────────┐
│  fsm_entrada_datos   │
└──────────┬───────────┘
           │ operando_a[9:0], operando_b[9:0], suma_valida
```

## Módulos
- [Sincronizador](Modulo-sincronizador)
- [Debounce](Modulo-debounce)
- [Barrido Teclado](Modulo-barrido-teclado)
- [Decodificador Tecla](Modulo-decodificador-tecla)
- [FSM Entrada Datos](Modulo-FSM-entrada-datos)

## Conexión física

| Pin FPGA | Terminal teclado | Señal |
|---|---|---|
| 51 | 1 (Fila 1: 1,2,3,A) | out_fil[0] |
| 53 | 2 (Fila 2: 4,5,6,B) | out_fil[1] |
| 54 | 3 (Fila 3: 7,8,9,C) | out_fil[2] |
| 55 | 4 (Fila 4: *,0,#,D) | out_fil[3] |
| 56 | 5 (Col 1: 1,4,7,*) | in_col[0] |
| 57 | 6 (Col 2: 2,5,8,0) | in_col[1] |
| 68 | 7 (Col 3: 3,6,9,#) | in_col[2] |
| 69 | 8 (Col 4: A,B,C,D) | in_col[3] |
