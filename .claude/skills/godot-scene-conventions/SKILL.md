---
name: godot-scene-conventions
description: Use al crear o reorganizar escenas, scripts, nodos o recursos en ArenalFighters. Define la estructura de carpetas y los patrones de Godot 4 del proyecto.
---

# godot-scene-conventions

## Estructura de carpetas

```
scenes/      # archivos .tscn
scripts/     # archivos .gd (uno por escena cuando aplica)
data/        # recursos .tres (frame data de personajes, configs)
sprites/     # imágenes y animaciones
docs/        # documentación del proyecto
```

## Nombres

- **Nodos:** `PascalCase` (`Fighter`, `Hitbox`, `AnimatedSprite2D`).
- **Scripts/escenas:** `snake_case`; el script de una escena se llama igual que la escena
  (`fighter.tscn` ↔ `fighter.gd`).
- **Variables/funciones:** `snake_case`. **Constantes:** `UPPER_CASE`. **Clases:** `PascalCase`.
- Tipado explícito siempre que se pueda: `var health: int = 100`.

## Patrones Godot 4 del proyecto

- **Separación simulación/render (LEY #1):** los nodos de presentación (`AnimatedSprite2D`,
  partículas, cámara, audio) leen el estado de la simulación pero **no** lo modifican.
- **Sin lógica de combate en `_process`/`_physics_process` con `delta` variable.** La simulación
  avanza en un tick fijo controlado (definido en Spec 01).
- **Datos en recursos, no en código:** los stats por personaje van en `.tres`, no hardcodeados.
- **Señales** para comunicación render/UI; **no** para lógica de simulación que requiera orden
  determinista.
- **Autoloads/singletons** mínimos y explícitos; documentar cada uno en el spec que lo introduce.

## Antes de commitear

- ¿El script está en `scripts/` y la escena en `scenes/`?
- ¿Los datos de balance están en `data/` y no hardcodeados?
- ¿La simulación respeta la LEY #1? (correr `determinism-check`).
