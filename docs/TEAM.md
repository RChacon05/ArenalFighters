# TEAM — Reparto de trabajo y flujo de colaboración

Proyecto de 2 personas. La división sigue la misma costura que impone el determinismo:
**simulación** por un lado, **presentación/contenido** por el otro.

## Pistas y responsables

### Pista A — Simulación & Netcode · **RChacon05**
La ingeniería determinista. Custodia la LEY #1 (ver `CLAUDE.md`). Corre el agente
`replay-determinism-tester` antes de mergear cualquier cambio de simulación.
- Specs: **01** (sim) · **03** (combos/inputs) · **06** (lógica de IA) · **08** (rollback).
- También: **02** lógica de combate/hitboxes, **10** detección de input de fatality.

### Pista B — Presentación, Shell & Contenido · **JeffLcTec**
Todo lo que *lee* el estado de la simulación o vive como sub-proyecto aparte.
- Specs: **05** (menús) · **07** (servidor de señalización) · **09** (lobby UX) · **11** (pulido).
- También: render/animaciones, **02** datos de personajes (`.tres` y sprites), UI de vida,
  **10** animaciones de fatality.

## Regla de oro

**La Pista B nunca escribe en el estado de la simulación; solo lo lee.** Es la LEY #1 convertida
en contrato de equipo. Elimina casi todos los conflictos de merge.

El contrato entre ambas pistas son los structs `InputCommand`, `FighterState` y `SimState`
(definidos en Spec 01). Una vez fijos, ambas pistas avanzan en paralelo sin pisarse.

## Cómo paralelizar desde el día uno

Casi todo depende del Spec 01 (trabajo de Pista A). Mientras A lo construye, B trabaja en cosas
100% independientes:
- **Servidor de señalización** (Spec 07): WebSocket mínimo en Node/Deno, no toca Godot, costo $0.
- **Menús** (Spec 05): pantallas que aún no necesitan combate real.
- **Pipeline de arte**: organizar sprites y definir el formato del recurso de datos del personaje.

## Flujo git

1. **Una rama por spec/feature.** Nunca commits directos a `main`.
   Nombres: `spec-01-sim`, `spec-05-menus`, `signaling-server`, etc.
2. **Pull Request + review de la otra persona** antes de mergear. El que no escribió el código
   lo revisa.
3. **Los tests de determinismo son el portero:** ningún PR que toque la simulación se mergea con
   `replay-determinism-tester` en rojo.
4. **`git pull` al empezar cada sesión** para no divergir.
5. Mensajes de commit y PRs siguen la skill `commit-pr-style` (en inglés, formato fijo).

## Estado de asignación por spec

Ver la columna "Responsable" en `docs/PROGRESS.md`.
