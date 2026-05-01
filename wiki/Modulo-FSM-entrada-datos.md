# Módulo: fsm_entrada_datos.sv

## Función
Controla el flujo de ingreso de datos de la calculadora mediante una máquina de estados finitos de 4 estados.

## Puertos

| Puerto | Dirección | Bits | Descripción |
|---|---|---|---|
| `clk` | input | 1 | Reloj 27 MHz |
| `rst_n` | input | 1 | Reset activo en bajo |
| `tecla_valida` | input | 1 | Pulso de nueva tecla detectada |
| `digito[3:0]` | input | 4 | Dígito decimal ingresado |
| `es_numero` | input | 1 | Indica si la tecla es numérica |
| `confirmar_a` | input | 1 | Tecla A presionada |
| `ejecutar` | input | 1 | Tecla B presionada |
| `limpiar` | input | 1 | Tecla D presionada |
| `operando_a[9:0]` | output | 10 | Primer operando almacenado |
| `operando_b[9:0]` | output | 10 | Segundo operando almacenado |
| `suma_valida` | output | 1 | Pulso para activar el sumador |
| `estado_dbg[1:0]` | output | 2 | Estado actual para debug/display |

## Diagrama de estados

```
         ┌─────────────────────────────────────────┐
         │              limpiar (D)                │
         ▼                                         │
      [IDLE] ──── es_numero ────► [INGRESO_A] ─────┤
         ▲                              │          │
         │                      confirmar_a (A)    │
         │                              │          │
         │                              ▼          │
         │                        [INGRESO_B] ─────┤
         │                              │          │
         │                      ejecutar (B)       │
         │                              │          │
         │                              ▼          │
         └──────── limpiar (D) ── [RESULTADO] ─────┘
```

## Comportamiento por estado

| Estado | Valor estado_dbg | Display muestra | Acción al presionar número |
|---|---|---|---|
| IDLE | 3 | 0000 | Inicia ingreso de operando A |
| INGRESO_A | 0 | operando_a | Agrega dígito a operando A (máx 3) |
| INGRESO_B | 1 | operando_b | Agrega dígito a operando B (máx 3) |
| RESULTADO | 2 | resultado | No acepta más dígitos |

## Acumulación de dígitos
```
registro = registro * 10 + digito_nuevo
Ejemplo: 1 → 1, luego 2 → 12, luego 3 → 123
```

## Código fuente
Ver [fsm_entrada_datos.sv](../src/design/fsm_entrada_datos.sv)
