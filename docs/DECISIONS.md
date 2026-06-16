# DECISIONS — Registro de decisiones (ADRs)

Decisiones de arquitectura con fecha y justificación. Append-only: si una decisión se
revierte, se agrega una nueva entrada que la supersede en vez de borrar la vieja.

---

## ADR-001 — Transporte online: WebRTC P2P + señalización gratis
- **Fecha:** 2026-06-15 · **Estado:** aceptada
- **Contexto:** El online debe tener costo $0.
- **Decisión:** WebRTC P2P entre los 2 jugadores, con un servidor de señalización mínimo
  hospedado en free tier (Render/Fly.io/Deno Deploy). Soportado nativo por Godot.
- **Consecuencias:** No hay servidor autoritativo; la lógica corre en los clientes (requiere
  determinismo). El servidor de señalización solo intermedia el handshake.

## ADR-002 — Netcode: Rollback
- **Fecha:** 2026-06-15 · **Estado:** aceptada
- **Contexto:** Se busca la mejor sensación competitiva online posible.
- **Decisión:** Rollback netcode.
- **Consecuencias:** El determinismo pasa a ser la restricción central del proyecto (ver LEY #1
  en CLAUDE.md). El core de combate se construye determinista desde el Spec 01.

## ADR-003 — Orden: core local determinista primero
- **Fecha:** 2026-06-15 · **Estado:** aceptada
- **Contexto:** Depurar netcode sobre un core inestable es inviable.
- **Decisión:** Construir y estabilizar el core de combate local (Fase 1) antes del online (Fase 3),
  pero ya determinista desde el inicio.
- **Consecuencias:** Más disciplina temprana; mucho menos retrabajo al llegar al rollback.

## ADR-004 — Personajes data-driven con una sola clase Fighter
- **Fecha:** 2026-06-15 · **Estado:** aceptada
- **Contexto:** Alcance inicial pequeño, reuso máximo.
- **Decisión:** Una clase `Fighter` parametrizada por recursos de datos por personaje.
- **Consecuencias:** Balance y nuevos personajes vía datos, no código nuevo.

## ADR-005 — IA local algorítmica que emite comandos de input
- **Fecha:** 2026-06-15 · **Estado:** aceptada
- **Contexto:** Modo local vs CPU sin romper determinismo.
- **Decisión:** IA por reglas/utility que produce los mismos comandos de input que un jugador.
- **Consecuencias:** La simulación no distingue jugador humano de CPU; sigue siendo reproducible.

## ADR-006 — Matemática de simulación en enteros (punto fijo, subpíxeles)
- **Fecha:** 2026-06-15 · **Estado:** aceptada
- **Contexto:** El float IEEE-754 puede divergir entre máquinas y rompería el rollback (LEY #1 regla 6).
- **Decisión:** Posiciones, velocidades y aceleraciones en `int`, con `1 px = 1000 subunidades` (`SimConstants.SUBPIXEL`). Constantes derivadas del juego original a ticks de 60 Hz: `GRAVITY = 270`, `MOVE_SPEED = 5000`, `JUMP_VELOCITY = -8333`, `FLOOR_Y = 400000`.
- **Consecuencias:** Determinismo garantizado en el movimiento entre máquinas. El render divide por `SUBPIXEL` para dibujar en píxeles. La aritmética con trigonometría (rotaciones complejas) queda fuera del alcance del juego, lo cual es aceptable para un fighter 2D.
