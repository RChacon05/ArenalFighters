# ArenalFighters — Diseño Maestro

> Documento de spec maestro. Fuente de verdad de la que se derivan los 12 specs.
> Fecha: 2026-06-15 · Motor: Godot 4.4 · Estado: aprobado para descomposición.

---

## 1. Visión

Juego de peleas 2D estilo Mortal Kombat / Street Fighter. Alcance inicial: golpes y
combos sencillos, una sola clase de luchador parametrizada por datos, menú de inicio,
fatalities/finishers, modo local con CPU algorítmica, y **multijugador online de costo $0**.

El online es la prioridad de producto, pero se construye **al final**, sobre un core de
combate local que desde el día uno cumple las reglas que el online (rollback) exige.

## 2. Decisiones arquitectónicas (cerradas)

| Tema | Decisión | Razón |
|---|---|---|
| Motor | Godot 4.4 (proyecto ya iniciado) | Ya existe base funcional |
| Transporte online | WebRTC P2P + servidor de señalización en free tier | Costo $0, soportado nativo por Godot |
| Modelo de netcode | **Rollback** sobre core determinista | Mejor sensación competitiva; exige determinismo |
| Orden de construcción | Core local determinista → shell → online → fatalities/pulido | Depurar netcode sobre core inestable es inviable |
| Personajes | Una clase `Fighter` + recursos de datos por personaje | Reuso máximo, balance data-driven |
| IA local | Algorítmica (reglas/utility), emite los mismos comandos de input que un jugador | Mantiene determinismo, reusa la simulación |
| Documentación | `CLAUDE.md` raíz + `docs/` estructurada | Estándar Claude Code, carga automática por sesión |
| Flujo de trabajo | Planes escritos siempre; tests/TDD en determinismo y netcode | Rigor medio: rápido pero seguro donde importa |

## 3. ⚠️ Invariantes de determinismo (LEY #1)

Rollback re-simula el pasado. **La misma secuencia de inputs DEBE producir el mismo estado
bit por bit en ambas máquinas.** Toda decisión de código se mide contra estas reglas:

1. **La simulación nunca lee `Input` directamente.** Recibe un struct de comandos por frame.
2. **Paso de tiempo fijo.** La simulación avanza en ticks fijos (p.ej. 60 Hz), nunca con
   `delta` variable. El render puede interpolar; la simulación no.
3. **Estado totalmente serializable.** Todo lo que afecta el resultado del combate se puede
   guardar y restaurar (snapshot) en cualquier tick.
4. **Sin aleatoriedad no sembrada.** Nada de `randf()`/`randi()` libres. RNG determinista con
   seed sincronizado y avanzado dentro de la simulación.
5. **Sin dependencias de orden no determinista.** Cuidado con iterar `Dictionary` por orden de
   inserción, `get_children()` dependiente de timing, o señales que cambian orden de ejecución.
6. **Matemática determinista.** Evitar acumulación de float divergente; preferir enteros o
   punto fijo para la física del combate cuando sea práctico. Definir esto en Spec 01.
7. **Render y simulación separados.** Animaciones, partículas, cámara y sonido **no** influyen
   en el estado de la simulación.

> El `fighter.gd` actual viola 1, 2 y 3. El Spec 01 lo refactoriza antes de construir nada más.

## 4. Descomposición en specs

### Fase 0 — Infraestructura
- **Spec 00 · Fundación de documentación y convenciones**
  Entregables: `CLAUDE.md` raíz, `docs/PROGRESS.md`, `docs/LESSONS.md`, `docs/DECISIONS.md`,
  estructura de carpetas, convenciones GDScript/escenas, plantillas de spec.

### Fase 1 — Core de combate local determinista
- **Spec 01 · Simulación determinista**
  Paso fijo, comandos de input (struct), separación simulación/render, snapshot save/restore,
  RNG determinista, decisión float vs punto fijo. *Base de todo el proyecto.*
- **Spec 02 · Luchador data-driven**
  Clase `Fighter` + recurso de datos por personaje; frame data (startup/active/recovery);
  hitbox/hurtbox; vida; hitstun/blockstun; knockback; bloqueo.
- **Spec 03 · Combos e inputs especiales**
  Buffer de inputs, motion inputs (cuarto de círculo, etc.), cancels, cadenas de combo.
- **Spec 04 · Flujo de combate**
  Rounds, timer, KO, best-of, victoria/derrota, reinicio determinista.

### Fase 2 — Shell del juego
- **Spec 05 · Menús y navegación**
  Menú de inicio, selección de modo (local / vs CPU / online), character select, opciones.
- **Spec 06 · Oponente CPU (algorítmico)**
  IA por reglas/utility que produce comandos de input; niveles de dificultad; sin romper
  determinismo (la IA es parte de la simulación o produce inputs reproducibles).

### Fase 3 — Online (rollback sobre WebRTC, costo $0)
- **Spec 07 · Transporte WebRTC + señalización**
  Servidor de señalización mínimo (WebSocket) en free tier (Render/Fly.io/Deno Deploy),
  lobby, establecimiento de conexión P2P, intercambio de seed.
- **Spec 08 · Rollback netcode**
  Predicción de input, save/restore de estado, resimulación, input delay configurable,
  detección de desync por checksum, manejo de reconexión. El spec más detallado.
- **Spec 09 · Flujo online / lobby UX**
  Conectar, mostrar ping, sync test inicial, manejo de desconexiones y abandono.

### Fase 4 — Jugo y contenido
- **Spec 10 · Fatalities / finishers**
  Detección de input de finisher al KO, ventana de oportunidad, animaciones especiales,
  gating por condiciones.
- **Spec 11 · Pulido**
  SFX, VFX, feedback de golpe (hitstop, screen shake), cámara, segundo personaje de ejemplo.

## 5. Infraestructura de documentación

```
CLAUDE.md                     # Lo que Claude lee cada sesión: visión, invariantes, navegación
docs/
  PROGRESS.md                 # Estado por spec: pendiente / en curso / hecho + notas
  LESSONS.md                  # Errores cometidos + causa raíz + regla para no repetirlos
  DECISIONS.md                # ADRs: decisiones con fecha y justificación
  specs/
    00-documentation.md
    01-deterministic-sim.md
    ...
  superpowers/specs/          # Specs de diseño generados por brainstorming
```

- **PROGRESS.md** se actualiza al cerrar cada sesión de trabajo de un spec.
- **LESSONS.md** se actualiza cada vez que se comete (y corrige) un error reseñable; formato:
  `## <título corto>` + Qué pasó / Causa raíz / Regla para no repetirlo.
- **DECISIONS.md** registra cambios de rumbo arquitectónicos.

## 6. Skills, agentes y MCPs

**Skills (`.claude/skills/`)**
- `determinism-check` — checklist anti-rollback-breakers; se invoca antes de cerrar código de simulación.
- `fighter-frame-data` — cómo definir/balancear moves y dónde viven los datos.
- `session-context` — rutina de inicio/cierre: leer CLAUDE.md+PROGRESS+LESSONS; actualizar al terminar.
- `godot-scene-conventions` — nombres de nodos, ubicación de escenas/scripts/recursos, patrones Godot 4.

**Agentes (`.claude/agents/`)**
- `replay-determinism-tester` — corre headless, reproduce inputs grabados, compara checksums por frame.
- `netcode-desync-debugger` — aísla el frame y campo de estado que divergió en un desync.

**MCPs**
- Godot MCP (comunitario, `@coding-solo/godot-mcp`) — lanzar escenas, correr el proyecto, leer logs.
- GitHub MCP (oficial, HTTP) — issues/PRs y despliegue del servidor de señalización.

## 7. Flujo de trabajo por spec

1. Brainstorming corto del spec (si hace falta) → 2. Plan escrito (`writing-plans`) →
3. Implementación (TDD en determinismo/netcode; libre en UI) →
4. `determinism-check` si toca simulación → 5. Actualizar PROGRESS/LESSONS → 6. Commit.

## 8. No-objetivos (YAGNI por ahora)

- Más de ~2 personajes en v1.
- Matchmaking con cuentas/ranking (solo lobby por código).
- Mobile/consolas (solo desktop).
- Tienda, cosméticos, progresión.
- Más de 1v1.
