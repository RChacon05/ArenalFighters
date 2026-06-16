# PROGRESS — ArenalFighters

Estado de avance por spec. Se actualiza al cerrar cada sesión de trabajo.
Estados: ⬜ pendiente · 🟨 en curso · ✅ hecho.

Responsables: **Pista A** (simulación/netcode) = RChacon05 · **Pista B** (shell/contenido) = JeffLcTec.
Ver reparto completo y flujo git en `docs/TEAM.md`.

| Spec | Título | Estado | Responsable | Notas |
|---|---|---|---|---|
| 00 | Documentación y convenciones | 🟨 | Ambos | CLAUDE.md, PROGRESS, LESSONS, DECISIONS, skills y agentes creados. Falta cerrar con review. |
| 01 | Simulación determinista | ✅ | A · RChacon05 | Paso fijo 60Hz, InputCommand, RNG sembrado, SimState con serialize/checksum, Simulation.advance, render desacoplado (FighterView+SimDriver). Tests de replay y rollback verdes. ADR-006 (punto fijo entero). |
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
- Godot MCP instalado y operativo con `GODOT_PATH` apuntando a Godot 4.4.1.
- Reparto de equipo definido (`docs/TEAM.md`): Pista A = RChacon05, Pista B = JeffLcTec.
- Skill `commit-pr-style` creada (Conventional Commits en inglés, sin `Co-Authored-By`).
- **Spec 01 cerrado** en rama `spec-01-sim`: simulación determinista a 60 Hz con punto fijo entero
  (ADR-006). Stack: `SimConstants`, `InputCommand`, `DeterministicRng` (xorshift64*), `FighterState`,
  `SimState` (serialize + FNV-1a checksum), `Simulation.advance`. Render desacoplado vía
  `FighterView` (solo lectura) y `SimDriver` (Input → comandos → advance 60Hz → views).
  Batería de tests headless: smoke, input_command, rng, sim_state, simulation (golden replay 120
  ticks), rollback_primitive. Todos verdes. UI temporalmente desconectada (se reconecta en Spec 02/04).
- Lecciones registradas: captura de output de Godot headless en PowerShell + literales hex int64
  con signo (ver `docs/LESSONS.md`).
