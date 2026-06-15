---
name: session-context
description: Use al EMPEZAR y al TERMINAR cada sesión de trabajo en ArenalFighters. Carga el contexto del proyecto al inicio y registra avances/lecciones al cierre.
---

# session-context

Rutina para que el contexto del proyecto persista entre sesiones y no se pierda nada.

## Al empezar la sesión

1. Leé `CLAUDE.md` (visión + LEY #1 de determinismo + convenciones).
2. Leé `docs/PROGRESS.md` — qué está hecho y en qué spec estamos.
3. Leé `docs/LESSONS.md` — errores ya cometidos. No los repitas.
4. Abrí el spec activo en `docs/specs/` y, si existe, su plan en `docs/superpowers/plans/`.
5. Resumí en 2-3 líneas dónde quedó el trabajo antes de continuar.

## Al terminar la sesión

1. Actualizá `docs/PROGRESS.md`:
   - Estado del spec (⬜/🟨/✅) y notas concretas.
   - Una entrada en "Bitácora de sesiones" con la fecha y lo avanzado.
2. Si cometiste y corregiste un error reseñable, agregá una entrada en `docs/LESSONS.md`
   (Qué pasó / Causa raíz / Regla para no repetirlo).
3. Si cambió una decisión de arquitectura, agregá un ADR en `docs/DECISIONS.md`.
4. Commit con mensaje descriptivo.

## Regla

Si el usuario dice "guardá el avance", "cerremos" o similar, ejecutá el bloque de cierre completo
antes de responder que terminaste.
