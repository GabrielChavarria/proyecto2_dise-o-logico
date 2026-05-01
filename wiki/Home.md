# Proyecto corto II — Diseño Digital Sincrónico en HDL

> **Curso:** EL-3307 Diseño Lógico | **Semestre:** I 2026 | **Profesor:** Oscar Caravaca

---

## Integrantes
| # | Nombre |
|---|---|
| 1 | Gabriel Alonso Chavarría Rodriguez |
| 2 | Alberto Javier Arce Estrada |

---

## Descripción del Proyecto

Calculadora digital implementada en una FPGA Tang Nano 9k que captura dos números de hasta 3 dígitos desde un teclado hexadecimal, calcula su suma y la despliega en un display de 4 dígitos de 7 segmentos. Opera a 27 MHz bajo principios de diseño sincrónico.

---

## Índice de Páginas

### Diagramas
| # | Página | Descripción |
|---|---|---|
| 1 | [Diagrama General](Diagrama-General) | Arquitectura completa del sistema y ruta de datos |

---

### Subsistema 1 — Lectura del Teclado Hexadecimal
| # | Página | Descripción |
|---|---|---|
| 2 | [Subsistema Teclado](Subsistema-Teclado) | Visión general y diagrama del subsistema |
| 2.1 | [Módulo Sincronizador](Modulo-sincronizador) | Elimina metaestabilidad (2 FF en cascada) |
| 2.2 | [Módulo Debounce](Modulo-debounce) | Elimina rebotes mecánicos (20 ms) |
| 2.3 | [Módulo Barrido Teclado](Modulo-barrido-teclado) | Escaneo fila-columna con detección de tecla |
| 2.4 | [Módulo Decodificador Tecla](Modulo-decodificador-tecla) | Convierte fila-columna a dígito decimal |
| 2.5 | [Módulo FSM Entrada Datos](Modulo-FSM-entrada-datos) | Máquina de estados: IDLE → INGRESO_A → INGRESO_B → RESULTADO |

---

### Subsistema 2 — Suma Aritmética
| # | Página | Descripción |
|---|---|---|
| 3 | [Subsistema Suma](Subsistema-Suma) | Visión general del subsistema |
| 3.1 | [Módulo Sumador](Modulo-sumador) | Suma dos operandos de 10 bits → resultado 11 bits |

---

### Subsistema 3 — Display de 7 Segmentos
| # | Página | Descripción |
|---|---|---|
| 4 | [Subsistema Display](Subsistema-Display) | Visión general y conexión física |
| 4.1 | [Módulo Divisor Frecuencia](Modulo-divisor-frecuencia) | 27 MHz → pulso 1 kHz |
| 4.2 | [Módulo Decodificador 7seg](Modulo-decodificador-7seg) | BCD (0-9) → señales de segmentos |
| 4.3 | [Módulo Controlador Displays](Modulo-controlador-displays) | Multiplexeo de 4 dígitos a 1 kHz |

---

### Verificación y Simulaciones
| # | Página | Descripción |
|---|---|---|
| 5.1 | [Simulación Display](Simulacion-Display) | Verificación del multiplexeo mostrando 1234 |
| 5.2 | [Simulación Debounce](Simulacion-Debounce) | Verificación de eliminación de rebotes |

---

### Síntesis y Resultados
| # | Página | Descripción |
|---|---|---|
| 6.1 | [Recursos FPGA](Recursos-FPGA) | LUTs, FFs y consumo de potencia |
| 6.2 | [Timing](Timing) | Frecuencia máxima y análisis de timing |

---

## Uso Rápido de la Calculadora

```
1. Ingresá el primer número (0-999)
2. Presioná A para confirmar
3. Ingresá el segundo número (0-999)
4. Presioná B para ver la suma
5. Presioná D para reiniciar
```

---

*Repositorio principal: [proyecto2_dise-o-logico](https://github.com/GabrielChavarria/proyecto2_dise-o-logico)*
