# Subsistema 2 — Suma Aritmética

## Descripción
Recibe los dos operandos almacenados por la FSM y calcula su suma sin signo cuando recibe la señal de habilitación.

## Diagrama de bloques

```
operando_a[9:0] ──┐
                  ├──► [sumador] ──► resultado[10:0]
operando_b[9:0] ──┘
suma_valida ──────────────────────►
```

## Módulos
- [Sumador](Modulo-sumador)

## Especificaciones

| Parámetro | Valor |
|---|---|
| Bits operando A | 10 (máx 999) |
| Bits operando B | 10 (máx 999) |
| Bits resultado | 11 (máx 1998) |
| Latencia | 1 ciclo de reloj |
