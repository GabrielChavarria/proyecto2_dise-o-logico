# 5.2 Simulación del Debounce

## Testbench: `tb_debounce.sv`

### Objetivo
Verificar que el módulo ignora rebotes mecánicos y solo acepta señales estables durante 20ms.

### Configuración
- Reloj: 27 MHz
- TICKS: 20 (20ms de estabilidad requerida)
- Rebotes simulados: 5 rebotes de 2ms cada uno
- Tiempo de estabilidad: 25ms

### Resultados obtenidos

```
--- Prueba 1: tecla presionada con rebote ---
senal_out antes: 1
t=38ms | senal_in=0 | senal_out=0  ← acepta después de 20ms estables
senal_out despues de estabilizar: 0

--- Prueba 2: tecla soltada con rebote ---
t=89ms | senal_in=1 | senal_out=1  ← acepta liberación después de 20ms
senal_out al soltar: 1
```

### Análisis
- La señal de salida no cambia durante los rebotes ✓
- Solo acepta el cambio después de 20ms consecutivos de señal estable ✓
- El comportamiento es simétrico para presión y liberación ✓
- El retardo de ~38ms es imperceptible para el usuario ✓
