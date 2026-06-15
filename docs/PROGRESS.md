# PROGRESS — ArenalFighters

Estado de avance por spec. Se actualiza al cerrar cada sesión de trabajo.
Estados: ⬜ pendiente · 🟨 en curso · ✅ hecho.

| Spec | Título | Estado | Notas |
|---|---|---|---|
| 00 | Documentación y convenciones | 🟨 | CLAUDE.md, PROGRESS, LESSONS, DECISIONS, skills y agentes creados. Falta cerrar con review. |
| 01 | Simulación determinista | ⬜ | Próximo. Refactor de `fighter.gd` a input-command + paso fijo + snapshots. |
| 02 | Luchador data-driven | ⬜ | |
| 03 | Combos e inputs especiales | ⬜ | |
| 04 | Flujo de combate | ⬜ | |
| 05 | Menús y navegación | ⬜ | |
| 06 | Oponente CPU algorítmico | ⬜ | |
| 07 | Transporte WebRTC + señalización | ⬜ | |
| 08 | Rollback netcode | ⬜ | |
| 09 | Flujo online / lobby UX | ⬜ | |
| 10 | Fatalities / finishers | ⬜ | |
| 11 | Pulido | ⬜ | |

## Bitácora de sesiones

### 2026-06-15
- Diseño maestro definido y commiteado.
- Spec 00: creada infraestructura de docs (CLAUDE.md, PROGRESS, LESSONS, DECISIONS),
  skills (`determinism-check`, `fighter-frame-data`, `session-context`, `godot-scene-conventions`)
  y agentes (`replay-determinism-tester`, `netcode-desync-debugger`).
- Godot MCP instalado. GitHub MCP pendiente (requiere PAT del usuario).
