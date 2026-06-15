---
name: determinism-check
description: Use ANTES de cerrar o commitear cualquier código de simulación de combate en ArenalFighters. Verifica que el código no rompa el determinismo que el rollback netcode exige.
---

# determinism-check

Rollback re-simula el pasado. Si la simulación no es determinista, hay desyncs imposibles de
depurar. Pasá este checklist sobre cada código que toque el estado del combate.

## Checklist (todo debe ser ✅)

1. **¿Lee `Input` directo?** La simulación NO debe llamar a `Input.is_action_*` ni leer teclado.
   Debe recibir un struct de comandos por frame. ❌ si encontrás `Input.` dentro de la sim.
2. **¿Usa `delta` variable?** La sim avanza en ticks fijos. ❌ si la lógica de combate usa el
   `delta` de `_process`/`_physics_process` para calcular movimiento o tiempos.
3. **¿El estado es serializable?** Todo lo que afecta el resultado debe poder guardarse y
   restaurarse. ❌ si hay estado en nodos no serializables, timers de engine, o tweens.
4. **¿Hay RNG no sembrado?** ❌ si ves `randf()`, `randi()`, `randf_range()` libres. Debe usar
   un RNG determinista con seed que avanza dentro de la sim.
5. **¿Depende de orden no determinista?** ❌ si itera `Dictionary` asumiendo orden, depende del
   orden de `get_children()` por timing, o de orden de emisión de señales.
6. **¿Matemática divergente?** Revisá acumulación de float. Preferí enteros/punto fijo en física
   de combate (según la decisión del Spec 01).
7. **¿Render contamina la sim?** ❌ si animaciones, partículas, cámara o sonido modifican estado
   de simulación. El render solo lee la sim, nunca la escribe.

## Si algo falla

- No lo dejes pasar "porque todavía no hay online". El determinismo se rompe en silencio y se
  paga carísimo en la Fase 3.
- Corregí, y si fue un patrón fácil de repetir, registralo en `docs/LESSONS.md`.

## Prueba de oro

Cuando exista el agente `replay-determinism-tester`: grabá una secuencia de inputs, corré la
sim dos veces y compará el checksum del estado por frame. Mismo input → mismo checksum.
