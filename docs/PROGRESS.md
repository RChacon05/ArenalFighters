# PROGRESS — ArenalFighters

Estado de avance por spec. Se actualiza al cerrar cada sesión de trabajo.
Estados: ⬜ pendiente · 🟨 en curso · ✅ hecho.

Responsables: **Pista A** (simulación/netcode) = RChacon05 · **Pista B** (shell/contenido) = JeffLcTec.
Ver reparto completo y flujo git en `docs/TEAM.md`.

| Spec | Título | Estado | Responsable | Notas |
|---|---|---|---|---|
| 00 | Documentación y convenciones | 🟨 | Ambos | CLAUDE.md, PROGRESS, LESSONS, DECISIONS, skills y agentes creados. Falta cerrar con review. |
| 01 | Simulación determinista | ⬜ | A · RChacon05 | Próximo. Refactor de `fighter.gd` a input-command + paso fijo + snapshots. |
| 02 | Luchador data-driven | ⬜ | A (lógica) · B (datos/sprites) | |
| 03 | Combos e inputs especiales | ⬜ | A · RChacon05 | |
| 04 | Flujo de combate | ⬜ | A · RChacon05 | |
| 05 | Menús y navegación | ⬜ | B · JeffLcTec | |
| 06 | Oponente CPU algorítmico | ⬜ | A · RChacon05 | |
| 07 | Transporte WebRTC + señalización | ⬜ | B · JeffLcTec | Sub-proyecto independiente; se puede arrancar ya. |
| 08 | Rollback netcode | ⬜ | A · RChacon05 | |
| 09 | Flujo online / lobby UX | ⬜ | B · JeffLcTec | |
| 10 | Fatalities / finishers | ⬜ | A (input) · B (animación) | |
| 11 | Pulido | ⬜ | B · JeffLcTec | |

## Bitácora de sesiones

### 2026-06-15
- Diseño maestro definido y commiteado.
- Spec 00: creada infraestructura de docs (CLAUDE.md, PROGRESS, LESSONS, DECISIONS),
  skills (`determinism-check`, `fighter-frame-data`, `session-context`, `godot-scene-conventions`)
  y agentes (`replay-determinism-tester`, `netcode-desync-debugger`).
- Godot MCP instalado. GitHub MCP pendiente (requiere PAT del usuario).
- Reparto de equipo definido (`docs/TEAM.md`): Pista A = RChacon05, Pista B = JeffLcTec.
- Skill `commit-pr-style` creada (Conventional Commits en inglés, sin `Co-Authored-By`).
