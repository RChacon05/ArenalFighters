---
name: fighter-frame-data
description: Use al definir, agregar o balancear un movimiento (move) de combate en ArenalFighters — golpes, especiales, combos. Explica qué es frame data y dónde viven los datos.
---

# fighter-frame-data

En un juego de peleas, cada ataque se describe por su **frame data** (medido en ticks de la
simulación de 60 Hz, no en segundos). Esto es lo que hace que combos y bloqueos se sientan justos.

## Anatomía de un move

| Campo | Qué es |
|---|---|
| `startup` | Frames desde que se presiona hasta que el hitbox se activa. Menor = más rápido. |
| `active` | Frames en que el hitbox puede golpear. |
| `recovery` | Frames después de `active` en que el luchador no puede actuar. |
| `damage` | Daño a la vida. |
| `hitstun` | Frames que el rival queda aturdido al ser golpeado (ventana para combear). |
| `blockstun` | Frames que el rival queda frenado si bloquea. |
| `knockback` | Empuje al impactar. |
| `cancels` | Qué moves pueden interrumpir este (para combos/cadenas). |
| `on_hit` / `on_block` | Ventaja/desventaja en frames (calculada o explícita). |

## Reglas

- **Todo en ticks enteros**, nunca en segundos ni `delta`. Es estado de simulación → determinista.
- Los datos viven en **recursos de datos** (`.tres`) por personaje, en `data/`, NO hardcodeados
  en el script del `Fighter`. Una sola clase `Fighter` los lee (ver ADR-004).
- Para que un move combee en otro: `hitstun_del_primero >= startup_del_segundo` (aprox).
- Balancear cambiando datos, no lógica. Si necesitás lógica nueva por move, reconsiderá el diseño.

## Al agregar un move

1. Definí su frame data en el recurso del personaje.
2. Verificá que los hitbox/hurtbox usen el sistema determinista (sin timers de engine).
3. Si toca la simulación, corré la skill `determinism-check` antes de cerrar.
4. Anotá el balance en el spec correspondiente (02 o 03).
