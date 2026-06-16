# PROGRESS — ArenalFighters

Estado de avance por spec. Se actualiza al cerrar cada sesión de trabajo.
Estados: ⬜ pendiente · 🟨 en curso · ✅ hecho · 🚫 cancelado.

Responsables: **Pista A** (combate/IA) = RChacon05 · **Pista B** (shell/contenido) = JeffLcTec.
Ver reparto completo en `docs/TEAM.md`.

| Spec | Título | Estado | Responsable | Notas |
|---|---|---|---|---|
| 00 | Documentación y convenciones | ✅ | Ambos | CLAUDE.md, docs, skills, agentes. Actualizado en pivot v2. |
| 01 | Luchador base mejorado | ⬜ | A · RChacon05 | Próximo. Extender `fighter.gd` con frame data y recursos `.tres`. |
| 02 | Combos e inputs especiales | ⬜ | A · RChacon05 | |
| 03 | Flujo de combate | ⬜ | A · RChacon05 | Rounds, timer, KO, best-of-3. |
| 04 | Menús y navegación | ⬜ | B · JeffLcTec | |
| 05 | Oponente CPU algorítmico | ⬜ | A · RChacon05 | |
| 06 | Modo historia | ⬜ | Ambos | Bloqueado hasta tener el guión/narrativa. |
| 07 | Fatalities / finishers | ⬜ | A (detección) · B (animación) | |
| 08 | Pulido | ⬜ | B · JeffLcTec | SFX, VFX, cámara, segundo personaje. |

## Specs cancelados (pivot 2026-06-16)

| Spec anterior | Título | Razón |
|---|---|---|
| 07 (v1) | Transporte WebRTC + señalización | Online eliminado del scope |
| 08 (v1) | Rollback netcode | Online eliminado del scope |
| 09 (v1) | Flujo online / lobby UX | Online eliminado del scope |

La rama `signaling-server` queda archivada, no se mergea a `main`.

## Bitácora de sesiones

### 2026-06-15
- Diseño maestro v1 definido (con online).
- Spec 00: infraestructura completa de docs, skills y agentes.
- Godot MCP instalado.
- Reparto de equipo: Pista A = RChacon05, Pista B = JeffLcTec.
- Skill `commit-pr-style` creada.
- Rama `signaling-server`: RChacon05 completó Spec 07 (señalización WebRTC).

### 2026-06-16
- **Pivot a MVP local 1v1.** Online eliminado del scope (ADR-007).
- Diseño maestro reescrito a v2 (8 specs, sin online).
- CLAUDE.md, PROGRESS, DECISIONS, TEAM actualizados.
- Rama `signaling-server` archivada sin merge.
- Spec 01 redefinido: extensión incremental de `fighter.gd`, sin reescritura determinista.
