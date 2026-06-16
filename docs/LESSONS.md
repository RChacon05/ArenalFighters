# LESSONS — Errores aprendidos

Cada vez que se comete (y corrige) un error reseñable, se registra acá para no repetirlo.
Claude debe leer este archivo al empezar cada sesión.

Formato de cada entrada:

```
## <título corto del error>
- **Fecha:** YYYY-MM-DD · **Spec:** NN
- **Qué pasó:** descripción del síntoma.
- **Causa raíz:** por qué ocurrió de verdad.
- **Regla para no repetirlo:** la lección accionable.
```

---

## Headless tests de Godot devolvían stdout vacío
- **Fecha:** 2026-06-15 · **Spec:** 01
- **Qué pasó:** Corriendo `godot --headless --script res://tests/test_runner.gd 2>&1 | Out-String` desde PowerShell, el comando devolvía solo el banner del engine, sin los `PASS/FAIL` ni `$LASTEXITCODE`. Además, el harness backgroundeaba la llamada y dejaba procesos Godot zombies acumulándose y pisándose sobre la cache `.godot/`.
- **Causa raíz:** En PowerShell 5.1, `2>&1` sobre ejecutables nativos envuelve stderr en `ErrorRecord` y rompe el `$LASTEXITCODE`. Y `run_in_background: true` cortaba la corrida antes de capturar stdout.
- **Regla para no repetirlo:** Para corridas headless de Godot, **siempre** usar `Start-Process -Wait -RedirectStandardOutput x.out -RedirectStandardError x.err`, leer ambos archivos al final, y nunca backgroundear. Si aparecen Godot zombies, matar solo los que no sean el editor del usuario (filtrar por `StartTime`).

## Literales hex `int64` que superan el rango con signo rompen silenciosamente
- **Fecha:** 2026-06-15 · **Spec:** 01
- **Qué pasó:** `DeterministicRng` usaba `0x9E3779B97F4A7C15` como seed fallback. Los tests pasaban verdes en stdout, pero stderr (que recién capturamos en este spec) repetía `ERROR: Cannot represent 0x9E3779B97F4A7C15 as a 64-bit signed integer`.
- **Causa raíz:** GDScript parsea literales hex como int64 con signo. Cualquier valor con el bit 63 en 1 (≥ `0x8000000000000000`) excede el rango y el parser lo descarta a 0.
- **Regla para no repetirlo:** Para seeds/constantes int64 en GDScript usar literales con el bit 63 en 0 (≤ `0x7FFF...`). Si necesitás el patrón "golden ratio" completo, escribirlo como dos halves o aceptar que va a quedar negativo y usarlo así.
