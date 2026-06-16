# DECISIONS — Registro de decisiones (ADRs)

Decisiones de arquitectura con fecha y justificación. Append-only: si una decisión se
revierte, se agrega una nueva entrada que la supersede en vez de borrar la vieja.

---

## ADR-001 — Transporte online: WebRTC P2P + señalización gratis
- **Fecha:** 2026-06-15 · **Estado:** ~~aceptada~~ **SUPERSEDADA por ADR-007**
- **Decisión original:** WebRTC P2P con señalización en free tier.
- **Supersedada porque:** el online fue eliminado del scope en ADR-007.

## ADR-002 — Netcode: Rollback
- **Fecha:** 2026-06-15 · **Estado:** ~~aceptada~~ **SUPERSEDADA por ADR-007**
- **Decisión original:** Rollback netcode para mejor sensación competitiva online.
- **Supersedada porque:** el online fue eliminado del scope en ADR-007.

## ADR-003 — Orden: core local determinista primero
- **Fecha:** 2026-06-15 · **Estado:** ~~aceptada~~ **SUPERSEDADA por ADR-007**
- **Decisión original:** Construir core determinista antes del online.
- **Supersedada porque:** sin online, no se necesita determinismo estricto.

## ADR-004 — Personajes data-driven con una sola clase Fighter
- **Fecha:** 2026-06-15 · **Estado:** aceptada — sigue vigente
- **Contexto:** Alcance inicial pequeño, reuso máximo.
- **Decisión:** Una clase `Fighter` parametrizada por recursos de datos por personaje.
- **Consecuencias:** Balance y nuevos personajes vía datos, no código nuevo.

## ADR-005 — IA local algorítmica
- **Fecha:** 2026-06-15 · **Estado:** aceptada — sigue vigente (simplificada)
- **Contexto:** Modo local vs CPU.
- **Decisión:** IA por reglas/utility que lee el estado del juego y genera inputs como player 2.
- **Consecuencias:** Simple de implementar; no necesita arquitectura especial.

## ADR-006 — Runtime del servidor de señalización: Deno Deploy
- **Fecha:** 2026-06-15 · **Estado:** ~~aceptada~~ **SUPERSEDADA por ADR-007**
- **Decisión original:** Deno Deploy para el servidor de señalización WebSocket.
- **Supersedada porque:** el servidor de señalización ya no existe en el scope.

## ADR-007 — Pivot a MVP local 1v1; eliminación del online
- **Fecha:** 2026-06-16 · **Estado:** aceptada
- **Contexto:** El stack online (WebRTC + rollback netcode + señalización) resultó
  desproporcionadamente complejo para el estado actual del proyecto. Los movimientos/ataques
  de cada luchador se vuelven mucho más difíciles de implementar correctamente bajo las
  restricciones de determinismo que el rollback exige. La simplicidad del `fighter.gd`
  original fue más valorada que la ambición del online.
- **Decisión:** El MVP es **local 1v1** en la misma máquina. El online queda fuera del scope
  indefinidamente. La rama `signaling-server` se archiva sin merge.
- **Consecuencias:**
  - ADRs 001, 002, 003 y 006 quedan supersedados.
  - El Spec 01 se redefine: extensión incremental de `fighter.gd`, sin reescritura determinista.
  - Los specs 07/08/09 (v1) quedan cancelados. Nuevo roadmap: 8 specs.
  - Se elimina la LEY #1 de CLAUDE.md; `determinism-check` archivada.
  - El código puede usar `Input` directo, `delta`, `move_and_slide()` sin restricciones.
