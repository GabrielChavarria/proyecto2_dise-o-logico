# 6.1 Recursos FPGA

## Herramientas
- **Síntesis**: Yosys 0.26+1
- **Place and Route**: nextpnr-gowin
- **Dispositivo**: GW1NR-LV9QN88PC6/I5 (TangNano 9k)

## Consumo de recursos

| Recurso | Utilizado | Disponible | Porcentaje |
|---|---|---|---|
| LUT4 | — | 8640 | — |
| DFF | — | 6693 | — |
| BSRAM | — | 26 | — |
| DSP | — | 20 | — |
| Pines IO | 23 | 72 | ~32% |

*Completar con datos reales del log `synthesis_tangnano9k.log`*

## Consumo de potencia

| Parámetro | Valor |
|---|---|
| Potencia estimada | — mW |

*Completar con datos reales del log `pnr_tangnano9k.log`*

## Distribución de pines utilizados

| Grupo | Pines |
|---|---|
| Display segmentos | 7 |
| Display ánodos | 4 |
| Teclado filas | 4 |
| Teclado columnas | 4 |
| Reloj | 1 |
| Reset (S1) | 1 |
| **Total** | **21** |
