# ArenalFighters — Contexto del proyecto

Juego de peleas 2D (estilo Mortal Kombat / Street Fighter) en **Godot 4.4**.
Foco de producto: **multijugador online de costo $0**. Se construye al final, sobre un core
de combate local que desde el día uno cumple las reglas de determinismo que el online exige.

## Al empezar cada sesión, leé esto

1. Este archivo (`CLAUDE.md`).
2. `docs/PROGRESS.md` — qué está hecho y en qué spec estamos.
3. `docs/LESSONS.md` — errores ya cometidos. **No los repitas.**
4. El spec activo en `docs/specs/`.

## Al terminar cada sesión

- Actualizá `docs/PROGRESS.md` con lo avanzado.
- Si cometiste y corregiste un error reseñable, registralo en `docs/LESSONS.md`.
- Si cambió una decisión de arquitectura, registrala en `docs/DECISIONS.md`.

## ⚠️ LEY #1 — Determinismo (innegociable)

Vamos a usar **rollback netcode**. Rollback re-simula el pasado, así que la misma secuencia de
inputs DEBE producir el mismo estado **bit por bit** en ambas máquinas. Todo el código de
simulación se mide contra estas reglas:

1. La simulación **nunca** lee `Input` directo — recibe un struct de comandos por frame.
2. **Paso de tiempo fijo** (60 Hz). Nunca `delta` variable en la simulación. El render interpola.
3. Estado **totalmente serializable** (snapshot save/restore en cualquier tick).
4. **Sin RNG no sembrado.** Nada de `randf()`/`randi()` libre; RNG determinista con seed.
5. **Sin orden no determinista** (cuidado con `Dictionary`, timing de señales, `get_children`).
6. **Matemática determinista** (ver decisión float vs punto fijo en Spec 01).
7. **Render y simulación separados.** Anim/partículas/cámara/sonido no tocan el estado.

Antes de cerrar cualquier código de simulación, invocá la skill `determinism-check`.

## Roadmap (12 specs, 4 fases)

- **Fase 0:** 00 documentación.
- **Fase 1 (core local determinista):** 01 simulación · 02 luchador · 03 combos · 04 flujo de combate.
- **Fase 2 (shell):** 05 menús · 06 CPU algorítmica.
- **Fase 3 (online):** 07 WebRTC+señalización · 08 rollback · 09 lobby UX.
- **Fase 4 (jugo):** 10 fatalities · 11 pulido.

Diseño maestro completo: `docs/superpowers/specs/2026-06-15-arenal-fighters-master-design.md`.

## Convenciones

- **GDScript:** `snake_case` para variables/funciones, `PascalCase` para clases/nodos,
  `UPPER_CASE` para constantes. Tipado explícito siempre que se pueda (`var x: int = 0`).
- **Archivos:** scripts en `scripts/`, escenas en `scenes/`, recursos de datos en `data/`,
  sprites en `sprites/`. Nombre de script = nombre de su escena en `snake_case`.
- **Idioma:** código y nombres en inglés; comentarios y docs pueden ir en español.
- **Flujo:** plan escrito siempre; TDD en determinismo y netcode; commits pequeños y descriptivos.

## Estado actual del código

`scripts/fighter.gd` es la base original (input directo + `delta` variable + estado no
serializable). **Viola la LEY #1** y será refactorizado en el Spec 01. No construir nada nuevo
de simulación encima de él hasta ese refactor.
