# TEAM — Reparto de trabajo y flujo de colaboración

Proyecto de 2 personas. MVP: **local 1v1**. Sin online.
La división sigue la costura natural: **combate/lógica** por un lado,
**presentación/contenido** por el otro.

## Pistas y responsables

### Pista A — Combate & IA · **RChacon05**
La mecánica del juego: cómo se siente pelear.
- Specs: **01** (luchador base) · **02** (combos/inputs) · **03** (flujo de combate) ·
  **05** (CPU algorítmica) · **07** detección de fatality.
- También: frame data, hitboxes, lógica de daño, máquina de estados del luchador.

### Pista B — Shell & Contenido · **JeffLcTec**
Lo que el jugador ve antes y después de pelear.
- Specs: **04** (menús) · **06** (modo historia, cuando haya guión) ·
  **07** animaciones de fatality · **08** (pulido).
- También: sprites, recursos `.tres` de personajes, UI (barras de vida, timer),
  cámara, SFX/VFX.

## Regla de oro

**La Pista B no escribe lógica de combate; la Pista A no toca menús ni UI.**
El contrato entre ambas pistas es la API pública de `fighter.gd`
(señales, variables `@export`, métodos `take_damage`, etc.).

## Cómo paralelizar

En cuanto Spec 01 fije la API de `Fighter`, ambas pistas avanzan sin pisarse:
- A: combos, flujo de combate, CPU.
- B: menús, arte, character select, UI de combate.

Para el **modo historia** (Spec 06): bloqueado hasta que exista el guión/narrativa.
Cuando esté listo, es trabajo de ambas pistas (A implementa la secuencia de peleas,
B implementa las cutscenes y el flujo de pantallas).

## Flujo git

1. **Una rama por spec/feature.** Nunca commits directos a `main`.
   Nombres: `spec-01-fighter`, `spec-04-menus`, `spec-05-cpu`, etc.
2. **Pull Request + review de la otra persona** antes de mergear.
3. **`git pull` al empezar cada sesión** para no divergir.
4. Mensajes de commit y PRs siguen la skill `commit-pr-style` (inglés, sin `Co-Authored-By`).

## Estado de asignación por spec

Ver la columna "Responsable" en `docs/PROGRESS.md`.
