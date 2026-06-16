# ArenalFighters — Diseño Maestro (v2)

> Actualizado: 2026-06-16. Pivot a MVP local 1v1.
> El online (WebRTC, rollback, señalización) fue eliminado del scope.
> Ver ADR-007 en `docs/DECISIONS.md` para la justificación.

---

## 1. Visión

Juego de peleas 2D estilo Mortal Kombat / Street Fighter.
**MVP: local 1v1** en la misma máquina, con CPU algorítmica y un modo historia
(a implementar cuando la narrativa esté lista).

El foco es **sentirse bien de jugar**: golpes con peso, combos satisfactorios,
finishers espectaculares y un loop de combate pulido. Sin complejidad de netcode.

## 2. Decisiones arquitectónicas (cerradas)

| Tema | Decisión | Razón |
|---|---|---|
| Motor | Godot 4.4 | Proyecto ya iniciado con base funcional |
| Modo de juego | Local 1v1 (misma máquina) | MVP simple; online eliminado |
| Online | **Eliminado del scope** | Complejidad desproporcionada al estado del proyecto |
| Base del luchador | Extender `fighter.gd` original con mejoras incrementales | Funciona, es simple, se siente bien |
| Física | `CharacterBody2D` + `move_and_slide()` con `delta` | Enfoque nativo de Godot, sin complicaciones |
| Input | `Input` directo en `_physics_process` | Sin capas intermedias innecesarias |
| Personajes | Una clase `Fighter` + recursos de datos por personaje | Reuso máximo, balance data-driven |
| IA CPU | Algorítmica por reglas/utility, lee `Input` como player 2 | Simple y efectiva para modo local |
| Modo historia | Placeholder hasta que exista la narrativa | No bloquea el MVP |

## 3. Roadmap — 8 specs, 4 fases

### Fase 1 — Core de combate local
- **Spec 01 · Luchador base mejorado**
  Refactor incremental de `fighter.gd`: frame data (startup/active/recovery en frames),
  hitbox/hurtbox data-driven, bloqueo, hitstun, knockback, recursos `.tres` por personaje.
  Mantiene `Input` directo y `move_and_slide()` — sin sobre-ingeniería.

- **Spec 02 · Combos e inputs especiales**
  Buffer de inputs (8–12 frames), motion inputs (cuarto de círculo, etc.),
  cancelación de animaciones, cadenas de combo definidas en datos.

- **Spec 03 · Flujo de combate**
  Rounds, timer, KO, best-of-3, pantalla de victoria/derrota, reinicio de ronda.

### Fase 2 — Shell del juego
- **Spec 04 · Menús y navegación**
  Menú de inicio, selección de modo (1v1 local / vs CPU / historia),
  character select, opciones de audio/video.

- **Spec 05 · Oponente CPU algorítmico**
  IA por reglas/utility con niveles de dificultad.
  Lee estado del juego y genera inputs como si fuera player 2.

### Fase 3 — Modo historia
- **Spec 06 · Modo historia**
  A implementar cuando la narrativa esté lista. Estructura: secuencia de peleas
  con cutscenes/diálogos entre medio. Bloqueado hasta tener el guión.

### Fase 4 — Jugo y pulido
- **Spec 07 · Fatalities / finishers**
  Detección de input al KO, ventana de oportunidad, animaciones especiales.

- **Spec 08 · Pulido**
  SFX, VFX, feedback de golpe (hitstop, screen shake), cámara dinámica,
  segundo personaje de ejemplo.

## 4. Arquitectura del luchador

Basada en la estructura existente de `fighter.gd`, extendida de forma incremental:

```
scenes/
  fighter.tscn          # CharacterBody2D — no cambia la estructura base
  main.tscn             # Escena de combate
scripts/
  fighter.gd            # Clase base Fighter — se extiende en Spec 01
data/
  characters/
    fighter_a.tres      # FighterData resource — stats, frame data, moves
    fighter_b.tres
sprites/                # Sprites y animaciones (ya existente)
```

El `fighter.gd` lee sus stats de un `FighterData` resource exportado.
Los moves y su frame data viven en los `.tres`, no hardcodeados.

## 5. Infraestructura de documentación

```
CLAUDE.md               # Contexto de sesión: visión, convenciones, estado actual
docs/
  PROGRESS.md           # Estado por spec
  LESSONS.md            # Errores aprendidos
  DECISIONS.md          # ADRs
  TEAM.md               # Reparto de trabajo
  superpowers/
    specs/              # Docs de diseño (brainstorming)
    plans/              # Planes de implementación
```

## 6. Skills y agentes vigentes

**Skills activas:**
- `session-context` — rutina de inicio/cierre de sesión.
- `fighter-frame-data` — definir y balancear moves.
- `godot-scene-conventions` — estructura de archivos y nodos.
- `commit-pr-style` — formato de commits y PRs.

**Skills archivadas (online eliminado):**
- `determinism-check` — ya no aplica sin rollback.

**Agentes archivados:**
- `replay-determinism-tester`, `netcode-desync-debugger` — eliminados con el online.

## 7. No-objetivos (YAGNI)

- Online / multijugador de cualquier tipo.
- Rollback netcode / WebRTC / servidor de señalización.
- Más de 2 personajes en v1 del MVP.
- Matchmaking, cuentas, ranking.
- Mobile / consolas.
- Tienda, cosméticos, progresión.
