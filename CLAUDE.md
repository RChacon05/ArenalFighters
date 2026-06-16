# ArenalFighters — Contexto del proyecto

Juego de peleas 2D (estilo Mortal Kombat / Street Fighter) en **Godot 4.4**.
**MVP: local 1v1** en la misma máquina. El online fue eliminado del scope (ver ADR-007).

## Al empezar cada sesión, leé esto

1. Este archivo (`CLAUDE.md`).
2. `docs/PROGRESS.md` — qué está hecho y en qué spec estamos.
3. `docs/LESSONS.md` — errores ya cometidos. **No los repitas.**
4. El spec activo en `docs/specs/` o el plan en `docs/superpowers/plans/`.

## Al terminar cada sesión

- Actualizá `docs/PROGRESS.md` con lo avanzado.
- Si cometiste y corregiste un error reseñable, registralo en `docs/LESSONS.md`.
- Si cambió una decisión de arquitectura, registrala en `docs/DECISIONS.md`.

## Filosofía de código

El `fighter.gd` original era simple y funcionaba bien. Construimos **sobre** esa base
de forma incremental, sin sobre-ingeniería. Reglas:

1. **Input directo** — `Input.is_action_*` en `_physics_process` está bien. Sin capas intermedias.
2. **Física nativa de Godot** — `move_and_slide()` con `delta`. No reinventamos la física.
3. **Datos en recursos** — stats y frame data en archivos `.tres` por personaje, no hardcodeados.
4. **Una clase Fighter** — parametrizada por un `FighterData` resource. Sin herencia innecesaria.
5. **Sin complejidad prematura** — si no lo necesitamos ahora, no lo agregamos.

## Roadmap (8 specs, 4 fases)

- **Fase 1 (core local):** 01 luchador base · 02 combos · 03 flujo de combate.
- **Fase 2 (shell):** 04 menús · 05 CPU algorítmica.
- **Fase 3 (historia):** 06 modo historia (bloqueado hasta tener el guión).
- **Fase 4 (jugo):** 07 fatalities · 08 pulido.

Diseño maestro completo: `docs/superpowers/specs/2026-06-15-arenal-fighters-master-design.md`.

## Convenciones

- **GDScript:** `snake_case` para variables/funciones, `PascalCase` para clases/nodos,
  `UPPER_CASE` para constantes. Tipado explícito siempre que se pueda (`var x: int = 0`).
- **Archivos:** scripts en `scripts/`, escenas en `scenes/`, recursos en `data/`,
  sprites en `sprites/`. Nombre de script = nombre de su escena en `snake_case`.
- **Idioma:** código y nombres en inglés; comentarios y docs pueden ir en español.
- **Flujo:** plan escrito siempre; commits pequeños y descriptivos.
- **Commits y PRs:** seguir la skill `commit-pr-style` (Conventional Commits, en inglés, sin
  `Co-Authored-By` ni footers de generación).
- **Equipo:** reparto de trabajo en `docs/TEAM.md`. Pista A (combate/IA) = RChacon05;
  Pista B (shell/contenido) = JeffLcTec. Rama por spec + PR con review de la otra persona.

## Estado actual del código

`scripts/fighter.gd` — base funcional existente con máquina de estados (IDLE/WALK/JUMP/
ATTACK/HIT/DEAD), hitbox/hurtbox, animaciones y controles para 2 jugadores. Es el punto
de partida del Spec 01: se extiende con frame data y datos por personaje, sin reescritura total.
