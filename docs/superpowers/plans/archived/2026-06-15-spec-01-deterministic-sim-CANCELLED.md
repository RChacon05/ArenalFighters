# Spec 01 — Simulación Determinista · Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Construir el núcleo de simulación de combate determinista (paso fijo 60 Hz, inputs como comandos, estado serializable con snapshot/checksum, RNG sembrado) que el rollback netcode exigirá, y separar simulación de render.

**Architecture:** La simulación es GDScript puro (clases `RefCounted`, sin nodos, sin `_physics_process`). Toda la matemática de posición/velocidad usa **enteros en subpíxeles** (1 píxel = 1000 unidades) para evitar el no-determinismo del float entre máquinas. Un `Simulation.advance(commands)` avanza un tick. El render (`FighterView`) lee el estado y lo dibuja, sin nunca modificarlo. Tests headless verifican que la misma secuencia de inputs produce el mismo checksum por tick (la prueba de oro del determinismo).

**Tech Stack:** Godot 4.4, GDScript. Tests headless con un runner propio (sin dependencias externas) corrido vía `godot --headless --script`.

---

## Decisión clave de este spec (ADR a registrar)

**Matemática de simulación: enteros en subpíxeles (punto fijo simple), NO float.**
- `SUBPIXEL = 1000` → 1 píxel = 1000 unidades internas.
- Posiciones, velocidades y aceleraciones son `int`. El render divide por `SUBPIXEL` para dibujar.
- Razón: el float IEEE-754 puede divergir entre máquinas/compiladores; los enteros son idénticos
  siempre. Un fighter 2D no necesita trigonometría, así que el costo de no usar float es mínimo.
- Constantes derivadas del juego original (60 Hz): `GRAVITY = 270` (subpx/tick²),
  `MOVE_SPEED = 5000` (subpx/tick), `JUMP_VELOCITY = -8333` (subpx/tick), `FLOOR_Y = 400000`
  (origen del fighter en reposo = 400 px).

> Registrar esto como **ADR-006** en `docs/DECISIONS.md` al cerrar el spec.

## Estructura de archivos

```
scripts/sim/
  sim_constants.gd     # class_name SimConstants — constantes y bits de input
  input_command.gd     # class_name InputCommand — botones de un frame (bitmask)
  deterministic_rng.gd # class_name DeterministicRng — RNG sembrado y serializable
  fighter_state.gd     # class_name FighterState — estado serializable de un luchador
  sim_state.gd         # class_name SimState — estado completo (fighters + tick + rng)
  simulation.gd        # class_name Simulation — advance(commands) determinista
scripts/render/
  fighter_view.gd      # class_name FighterView — dibuja un FighterState (solo lectura)
  sim_driver.gd        # class_name SimDriver — Input real → comandos → advance 60Hz → views
tests/
  test_case.gd         # class_name SimTestCase — base de aserciones
  test_runner.gd       # SceneTree runner headless
  test_smoke.gd        # test trivial que valida el runner
  test_input_command.gd
  test_rng.gd
  test_sim_state.gd
  test_simulation.gd
  test_rollback_primitive.gd
```

`scripts/fighter.gd` original queda **obsoleto** tras este spec (su lógica se reimplementa en la
simulación). No se borra todavía: se desconecta de la escena en la Task 9 y se elimina en Spec 02.

---

## Task 1: Test harness headless

**Files:**
- Create: `tests/test_case.gd`
- Create: `tests/test_runner.gd`
- Create: `tests/test_smoke.gd`

- [ ] **Step 1: Crear la base de aserciones**

`tests/test_case.gd`:
```gdscript
class_name SimTestCase
extends RefCounted

var failures: Array[String] = []

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s (esperado %s, obtuvo %s)" % [message, str(expected), str(actual)])

# Cada test concreto sobreescribe esto.
func run() -> void:
	pass
```

- [ ] **Step 2: Crear el runner headless**

`tests/test_runner.gd`:
```gdscript
extends SceneTree

const TEST_SCRIPTS := [
	"res://tests/test_smoke.gd",
]

func _initialize() -> void:
	var total_failures := 0
	for path in TEST_SCRIPTS:
		var script: GDScript = load(path)
		var test: SimTestCase = script.new()
		test.run()
		if test.failures.is_empty():
			print("PASS  ", path)
		else:
			for f in test.failures:
				print("FAIL  ", path, " :: ", f)
			total_failures += test.failures.size()
	print("---")
	print("Total failures: ", total_failures)
	quit(0 if total_failures == 0 else 1)
```

- [ ] **Step 3: Crear el smoke test**

`tests/test_smoke.gd`:
```gdscript
extends SimTestCase

func run() -> void:
	eq(1 + 1, 2, "la aritmética básica funciona")
```

- [ ] **Step 4: Correr el runner y verificar que pasa**

Run: `godot --headless --script res://tests/test_runner.gd`
(Si `godot` no está en el PATH, usar la ruta completa del ejecutable de Godot 4.4, o el Godot MCP.)
Expected: salida con `PASS  res://tests/test_smoke.gd` y `Total failures: 0`, exit code 0.

- [ ] **Step 5: Commit**

```bash
git add tests/
git commit -m "test: add headless test harness (Spec 01)"
```

---

## Task 2: Constantes e InputCommand

**Files:**
- Create: `scripts/sim/sim_constants.gd`
- Create: `scripts/sim/input_command.gd`
- Create: `tests/test_input_command.gd`
- Modify: `tests/test_runner.gd` (registrar el nuevo test)

- [ ] **Step 1: Escribir el test que falla**

`tests/test_input_command.gd`:
```gdscript
extends SimTestCase

func run() -> void:
	var cmd := InputCommand.new()
	cmd.set_held(SimConstants.BTN_LEFT, true)
	cmd.set_held(SimConstants.BTN_ATTACK, true)
	check(cmd.is_held(SimConstants.BTN_LEFT), "LEFT debe estar presionado")
	check(cmd.is_held(SimConstants.BTN_ATTACK), "ATTACK debe estar presionado")
	check(not cmd.is_held(SimConstants.BTN_JUMP), "JUMP no debe estar presionado")
	# round-trip de serialización
	var packed := cmd.to_int()
	var restored := InputCommand.from_int(packed)
	eq(restored.buttons, cmd.buttons, "serialización round-trip preserva botones")
```

Registrar en `tests/test_runner.gd` agregando `"res://tests/test_input_command.gd"` al array `TEST_SCRIPTS`.

- [ ] **Step 2: Correr y verificar que falla**

Run: `godot --headless --script res://tests/test_runner.gd`
Expected: error de parseo / FAIL porque `InputCommand` y `SimConstants` no existen.

- [ ] **Step 3: Implementar las constantes**

`scripts/sim/sim_constants.gd`:
```gdscript
class_name SimConstants
extends RefCounted

# Frecuencia fija de la simulación.
const TICK_HZ := 60

# Punto fijo: 1 píxel = SUBPIXEL unidades internas (enteras).
const SUBPIXEL := 1000

# Física derivada del juego original, en unidades/tick.
const GRAVITY := 270          # subpx por tick, por tick
const MOVE_SPEED := 5000       # subpx por tick
const JUMP_VELOCITY := -8333   # subpx por tick
const FLOOR_Y := 400000        # subpx (origen del fighter en reposo = 400 px)

# Bits de input (bitmask de un frame).
const BTN_LEFT := 1 << 0
const BTN_RIGHT := 1 << 1
const BTN_JUMP := 1 << 2
const BTN_ATTACK := 1 << 3

# Estados del luchador.
enum State { IDLE, WALK, JUMP, ATTACK, HIT, DEAD }

# Duración en ticks de estados con tiempo fijo (placeholder; el combate real es Spec 02).
const ATTACK_TICKS := 30
const HIT_TICKS := 12
```

- [ ] **Step 4: Implementar InputCommand**

`scripts/sim/input_command.gd`:
```gdscript
class_name InputCommand
extends RefCounted

var buttons: int = 0

func set_held(bit: int, held: bool) -> void:
	if held:
		buttons |= bit
	else:
		buttons &= ~bit

func is_held(bit: int) -> bool:
	return (buttons & bit) != 0

func to_int() -> int:
	return buttons

static func from_int(value: int) -> InputCommand:
	var cmd := InputCommand.new()
	cmd.buttons = value
	return cmd
```

- [ ] **Step 5: Correr y verificar que pasa**

Run: `godot --headless --script res://tests/test_runner.gd`
Expected: `PASS  res://tests/test_input_command.gd`, `Total failures: 0`.

- [ ] **Step 6: Commit**

```bash
git add scripts/sim/sim_constants.gd scripts/sim/input_command.gd tests/test_input_command.gd tests/test_runner.gd
git commit -m "feat(sim): add SimConstants and InputCommand (Spec 01)"
```

---

## Task 3: RNG determinista

**Files:**
- Create: `scripts/sim/deterministic_rng.gd`
- Create: `tests/test_rng.gd`
- Modify: `tests/test_runner.gd`

- [ ] **Step 1: Escribir el test que falla**

`tests/test_rng.gd`:
```gdscript
extends SimTestCase

func run() -> void:
	var a := DeterministicRng.new(12345)
	var b := DeterministicRng.new(12345)
	# Misma seed → misma secuencia.
	for i in range(5):
		eq(a.next_int(), b.next_int(), "misma seed produce mismo valor en el paso %d" % i)
	# Estado serializable y restaurable.
	var saved := a.state
	var x := a.next_int()
	a.state = saved
	eq(a.next_int(), x, "restaurar el estado reproduce el mismo valor")
```

Registrar `"res://tests/test_rng.gd"` en `TEST_SCRIPTS`.

- [ ] **Step 2: Correr y verificar que falla**

Run: `godot --headless --script res://tests/test_runner.gd`
Expected: FAIL/parse error porque `DeterministicRng` no existe.

- [ ] **Step 3: Implementar el RNG (xorshift, entero, sin float)**

`scripts/sim/deterministic_rng.gd`:
```gdscript
class_name DeterministicRng
extends RefCounted

# xorshift64*, completamente determinista y serializable con un solo int.
var state: int

func _init(seed: int = 1) -> void:
	# Evitar estado 0 (xorshift se quedaría en 0).
	state = seed if seed != 0 else 0x9E3779B97F4A7C15

func next_int() -> int:
	state ^= state << 13
	state ^= state >> 7
	state ^= state << 17
	return state

# Entero determinista en [0, n).
func next_range(n: int) -> int:
	if n <= 0:
		return 0
	var v := next_int()
	if v < 0:
		v = -v
	return v % n
```

- [ ] **Step 4: Correr y verificar que pasa**

Run: `godot --headless --script res://tests/test_runner.gd`
Expected: `PASS  res://tests/test_rng.gd`, `Total failures: 0`.

- [ ] **Step 5: Commit**

```bash
git add scripts/sim/deterministic_rng.gd tests/test_rng.gd tests/test_runner.gd
git commit -m "feat(sim): add DeterministicRng (Spec 01)"
```

---

## Task 4: FighterState y SimState (serialización + checksum)

**Files:**
- Create: `scripts/sim/fighter_state.gd`
- Create: `scripts/sim/sim_state.gd`
- Create: `tests/test_sim_state.gd`
- Modify: `tests/test_runner.gd`

- [ ] **Step 1: Escribir el test que falla**

`tests/test_sim_state.gd`:
```gdscript
extends SimTestCase

func run() -> void:
	var s := SimState.new(2)
	s.fighters[0].pos_x = 12345
	s.fighters[1].pos_x = -678
	s.tick = 7

	# clone() es independiente (deep copy).
	var c := s.clone()
	c.fighters[0].pos_x = 999
	eq(s.fighters[0].pos_x, 12345, "clone no comparte referencias con el original")

	# Round-trip de serialización conserva el checksum.
	var bytes := s.serialize()
	var restored := SimState.deserialize(bytes)
	eq(restored.checksum(), s.checksum(), "serialize/deserialize conserva el checksum")
	eq(restored.tick, s.tick, "deserialize conserva el tick")

	# Estados distintos → checksums distintos.
	var d := s.clone()
	d.fighters[1].pos_x = 4242
	check(d.checksum() != s.checksum(), "estados distintos producen checksums distintos")
```

Registrar `"res://tests/test_sim_state.gd"` en `TEST_SCRIPTS`.

- [ ] **Step 2: Correr y verificar que falla**

Run: `godot --headless --script res://tests/test_runner.gd`
Expected: FAIL/parse error porque `SimState`/`FighterState` no existen.

- [ ] **Step 3: Implementar FighterState**

`scripts/sim/fighter_state.gd`:
```gdscript
class_name FighterState
extends RefCounted

# Todo entero (subpíxeles o enums). Nada de float: es estado determinista.
var pos_x: int = 0
var pos_y: int = 0
var vel_x: int = 0
var vel_y: int = 0
var facing: int = 1                      # 1 = mira a la derecha, -1 = izquierda
var state: int = SimConstants.State.IDLE
var state_timer: int = 0                 # ticks restantes del estado temporizado
var health: int = 100
var on_floor: bool = false
var prev_buttons: int = 0                # para derivar flancos (just_pressed)

func clone() -> FighterState:
	var f := FighterState.new()
	f.pos_x = pos_x
	f.pos_y = pos_y
	f.vel_x = vel_x
	f.vel_y = vel_y
	f.facing = facing
	f.state = state
	f.state_timer = state_timer
	f.health = health
	f.on_floor = on_floor
	f.prev_buttons = prev_buttons
	return f

# Orden FIJO de campos para serialización determinista.
func to_ints() -> Array[int]:
	return [pos_x, pos_y, vel_x, vel_y, facing, state, state_timer,
			health, 1 if on_floor else 0, prev_buttons]

func from_ints(v: Array) -> void:
	pos_x = v[0]; pos_y = v[1]; vel_x = v[2]; vel_y = v[3]
	facing = v[4]; state = v[5]; state_timer = v[6]
	health = v[7]; on_floor = v[8] != 0; prev_buttons = v[9]

const FIELD_COUNT := 10
```

- [ ] **Step 4: Implementar SimState**

`scripts/sim/sim_state.gd`:
```gdscript
class_name SimState
extends RefCounted

var tick: int = 0
var fighters: Array[FighterState] = []
var rng_state: int = 1

func _init(fighter_count: int = 2) -> void:
	for i in range(fighter_count):
		fighters.append(FighterState.new())

func clone() -> SimState:
	var s := SimState.new(0)
	s.tick = tick
	s.rng_state = rng_state
	for f in fighters:
		s.fighters.append(f.clone())
	return s

# Aplana TODO el estado en un orden fijo de enteros.
func _flatten() -> PackedInt64Array:
	var out := PackedInt64Array()
	out.append(tick)
	out.append(rng_state)
	out.append(fighters.size())
	for f in fighters:
		for n in f.to_ints():
			out.append(n)
	return out

func serialize() -> PackedByteArray:
	return _flatten().to_byte_array()

static func deserialize(bytes: PackedByteArray) -> SimState:
	var ints := bytes.to_int64_array()
	var s := SimState.new(0)
	s.tick = ints[0]
	s.rng_state = ints[1]
	var count := ints[2]
	var idx := 3
	for i in range(count):
		var f := FighterState.new()
		f.from_ints(ints.slice(idx, idx + FighterState.FIELD_COUNT))
		s.fighters.append(f)
		idx += FighterState.FIELD_COUNT
	return s

# FNV-1a de 32 bits sobre los bytes serializados. Determinista en el mismo build de engine.
func checksum() -> int:
	var bytes := serialize()
	var h := 2166136261
	for b in bytes:
		h = (h ^ b) & 0xFFFFFFFF
		h = (h * 16777619) & 0xFFFFFFFF
	return h
```

- [ ] **Step 5: Correr y verificar que pasa**

Run: `godot --headless --script res://tests/test_runner.gd`
Expected: `PASS  res://tests/test_sim_state.gd`, `Total failures: 0`.

- [ ] **Step 6: Commit**

```bash
git add scripts/sim/fighter_state.gd scripts/sim/sim_state.gd tests/test_sim_state.gd tests/test_runner.gd
git commit -m "feat(sim): add FighterState and SimState with checksum (Spec 01)"
```

---

## Task 5: Simulation.advance() — un tick determinista

**Files:**
- Create: `scripts/sim/simulation.gd`
- Create: `tests/test_simulation.gd`
- Modify: `tests/test_runner.gd`

- [ ] **Step 1: Escribir el test que falla (prueba de oro: replay)**

`tests/test_simulation.gd`:
```gdscript
extends SimTestCase

# Construye una secuencia de comandos fija para 2 luchadores durante N ticks.
func _make_inputs() -> Array:
	var seq: Array = []
	for t in range(120):
		var p1 := InputCommand.new()
		var p2 := InputCommand.new()
		if t < 30:
			p1.set_held(SimConstants.BTN_RIGHT, true)
		if t == 10:
			p1.set_held(SimConstants.BTN_JUMP, true)
		if t >= 40 and t < 70:
			p2.set_held(SimConstants.BTN_LEFT, true)
		seq.append([p1, p2])
	return seq

func _run_sim(seq: Array) -> Array[int]:
	var sim := Simulation.new(SimState.new(2))
	sim.state.fighters[0].pos_x = -300000
	sim.state.fighters[0].pos_y = SimConstants.FLOOR_Y
	sim.state.fighters[1].pos_x = 300000
	sim.state.fighters[1].pos_y = SimConstants.FLOOR_Y
	var checksums: Array[int] = []
	for commands in seq:
		sim.advance(commands)
		checksums.append(sim.state.checksum())
	return checksums

func run() -> void:
	var seq := _make_inputs()
	var a := _run_sim(seq)
	var b := _run_sim(seq)
	eq(a.size(), b.size(), "ambas corridas avanzan el mismo número de ticks")
	for i in range(a.size()):
		eq(a[i], b[i], "checksum idéntico en el tick %d (determinismo)" % i)
	# El movimiento realmente ocurrió (no es un no-op).
	check(a[a.size() - 1] != a[0], "el estado cambia a lo largo de la simulación")
```

Registrar `"res://tests/test_simulation.gd"` en `TEST_SCRIPTS`.

- [ ] **Step 2: Correr y verificar que falla**

Run: `godot --headless --script res://tests/test_runner.gd`
Expected: FAIL/parse error porque `Simulation` no existe.

- [ ] **Step 3: Implementar Simulation**

`scripts/sim/simulation.gd`:
```gdscript
class_name Simulation
extends RefCounted

var state: SimState
var rng: DeterministicRng

func _init(initial_state: SimState) -> void:
	state = initial_state
	rng = DeterministicRng.new(state.rng_state if state.rng_state != 0 else 1)

# Avanza exactamente un tick. commands = [InputCommand_p1, InputCommand_p2].
func advance(commands: Array) -> void:
	for i in range(state.fighters.size()):
		var cmd: InputCommand = commands[i]
		_advance_fighter(state.fighters[i], cmd)
	_update_facing()
	state.rng_state = rng.state
	state.tick += 1

func _advance_fighter(f: FighterState, cmd: InputCommand) -> void:
	if f.state == SimConstants.State.DEAD:
		f.prev_buttons = cmd.buttons
		return

	var just_pressed := cmd.buttons & ~f.prev_buttons

	# Temporizadores de estados bloqueantes (attack/hit).
	if f.state == SimConstants.State.ATTACK or f.state == SimConstants.State.HIT:
		f.state_timer -= 1
		if f.state_timer <= 0:
			f.state = SimConstants.State.IDLE
	else:
		# Iniciar ataque.
		if (just_pressed & SimConstants.BTN_ATTACK) != 0 and f.on_floor:
			f.state = SimConstants.State.ATTACK
			f.state_timer = SimConstants.ATTACK_TICKS

	var blocked := f.state == SimConstants.State.ATTACK or f.state == SimConstants.State.HIT

	# Movimiento horizontal (solo si no está bloqueado por un estado).
	if not blocked:
		var dir := 0
		if cmd.is_held(SimConstants.BTN_LEFT):
			dir -= 1
		if cmd.is_held(SimConstants.BTN_RIGHT):
			dir += 1
		f.vel_x = dir * SimConstants.MOVE_SPEED
	else:
		f.vel_x = 0

	# Salto.
	if not blocked and (just_pressed & SimConstants.BTN_JUMP) != 0 and f.on_floor:
		f.vel_y = SimConstants.JUMP_VELOCITY
		f.on_floor = false

	# Gravedad.
	f.vel_y += SimConstants.GRAVITY

	# Integración de posición (enteros).
	f.pos_x += f.vel_x
	f.pos_y += f.vel_y

	# Colisión con el suelo.
	if f.pos_y >= SimConstants.FLOOR_Y:
		f.pos_y = SimConstants.FLOOR_Y
		f.vel_y = 0
		f.on_floor = true

	# Estado visual derivado (no afecta determinismo, pero vive en el estado).
	if not blocked:
		if not f.on_floor:
			f.state = SimConstants.State.JUMP
		elif f.vel_x != 0:
			f.state = SimConstants.State.WALK
		else:
			f.state = SimConstants.State.IDLE

	f.prev_buttons = cmd.buttons

func _update_facing() -> void:
	if state.fighters.size() < 2:
		return
	var a := state.fighters[0]
	var b := state.fighters[1]
	a.facing = 1 if a.pos_x <= b.pos_x else -1
	b.facing = 1 if b.pos_x < a.pos_x else -1
```

- [ ] **Step 4: Correr y verificar que pasa**

Run: `godot --headless --script res://tests/test_runner.gd`
Expected: `PASS  res://tests/test_simulation.gd`, `Total failures: 0`.

- [ ] **Step 5: Correr la skill determinism-check**

Invocar la skill `determinism-check` sobre `scripts/sim/simulation.gd`. Confirmar: sin `Input.`,
sin `delta`, sin `randf`, sin orden no determinista, sin float. Si algo falla, corregir y anotar
en `docs/LESSONS.md`.

- [ ] **Step 6: Commit**

```bash
git add scripts/sim/simulation.gd tests/test_simulation.gd tests/test_runner.gd
git commit -m "feat(sim): add deterministic Simulation.advance with replay test (Spec 01)"
```

---

## Task 6: Primitiva de rollback (save / restore / resimulate)

**Files:**
- Create: `tests/test_rollback_primitive.gd`
- Modify: `tests/test_runner.gd`

Esta es la operación exacta que el rollback usará en la Fase 3: guardar un snapshot, seguir
simulando, restaurar, re-simular los mismos inputs, y obtener el mismo resultado.

- [ ] **Step 1: Escribir el test que falla**

`tests/test_rollback_primitive.gd`:
```gdscript
extends SimTestCase

func _commands(t: int) -> Array:
	var p1 := InputCommand.new()
	var p2 := InputCommand.new()
	if t % 4 == 0:
		p1.set_held(SimConstants.BTN_RIGHT, true)
	if t % 3 == 0:
		p2.set_held(SimConstants.BTN_LEFT, true)
	if t == 5:
		p1.set_held(SimConstants.BTN_JUMP, true)
	return [p1, p2]

func run() -> void:
	var sim := Simulation.new(SimState.new(2))
	sim.state.fighters[0].pos_y = SimConstants.FLOOR_Y
	sim.state.fighters[1].pos_y = SimConstants.FLOOR_Y

	# Avanzar hasta el tick 10 y guardar snapshot.
	for t in range(10):
		sim.advance(_commands(t))
	var snapshot := sim.state.serialize()

	# Avanzar 10 ticks más y registrar el checksum final.
	for t in range(10, 20):
		sim.advance(_commands(t))
	var expected := sim.state.checksum()

	# Restaurar el snapshot y re-simular exactamente los mismos inputs.
	sim.state = SimState.deserialize(snapshot)
	for t in range(10, 20):
		sim.advance(_commands(t))

	eq(sim.state.checksum(), expected, "resimular tras restaurar da el mismo estado (rollback)")
```

Registrar `"res://tests/test_rollback_primitive.gd"` en `TEST_SCRIPTS`.

- [ ] **Step 2: Correr y verificar que falla primero**

Antes de que exista el archivo, el runner no lo lista. Tras agregarlo al runner pero con un bug
introducido a propósito (opcional), debería fallar. Si el código de Tasks 1-5 es correcto, este
test pasa directo: es una prueba de regresión del determinismo, no de código nuevo.

Run: `godot --headless --script res://tests/test_runner.gd`
Expected: `PASS  res://tests/test_rollback_primitive.gd`.

- [ ] **Step 3: Commit**

```bash
git add tests/test_rollback_primitive.gd tests/test_runner.gd
git commit -m "test(sim): add rollback save/restore/resimulate regression (Spec 01)"
```

---

## Task 7: Capa de render — FighterView (solo lectura)

**Files:**
- Create: `scripts/render/fighter_view.gd`

`FighterView` toma un `FighterState` y actualiza la posición/animación/flip del `AnimatedSprite2D`.
Nunca escribe en el estado. Es un `Node2D` que envuelve la presentación.

- [ ] **Step 1: Implementar FighterView**

`scripts/render/fighter_view.gd`:
```gdscript
class_name FighterView
extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const ANIM_BY_STATE := {
	SimConstants.State.IDLE: "idle",
	SimConstants.State.WALK: "walk",
	SimConstants.State.JUMP: "jump",
	SimConstants.State.ATTACK: "attack",
	SimConstants.State.HIT: "hit",
	SimConstants.State.DEAD: "death",
}

# Llamado por el driver cada frame de render con el estado actual (solo lectura).
func render_state(f: FighterState) -> void:
	# Subpíxeles -> píxeles para dibujar.
	position.x = float(f.pos_x) / SimConstants.SUBPIXEL
	position.y = float(f.pos_y) / SimConstants.SUBPIXEL
	sprite.flip_h = f.facing < 0
	var anim: String = ANIM_BY_STATE.get(f.state, "idle")
	if sprite.animation != anim:
		sprite.play(anim)
```

- [ ] **Step 2: Verificación de parseo**

Run: `godot --headless --check-only --script res://scripts/render/fighter_view.gd`
Expected: sin errores de parseo. (No hay test unitario: es presentación; se valida en la Task 8.)

- [ ] **Step 3: Commit**

```bash
git add scripts/render/fighter_view.gd
git commit -m "feat(render): add FighterView read-only presentation (Spec 01)"
```

---

## Task 8: SimDriver — integrar Input real, simulación y render

**Files:**
- Create: `scripts/render/sim_driver.gd`
- Modify: `scenes/main.tscn` (cambiar el script de los fighters a FighterView, agregar el driver)
- Modify: `scripts/camera_2d.gd` (sin cambios de lógica; ya lee `global_position`, sigue válido)

El driver corre a paso fijo: acumula tiempo real, y por cada `1/60 s` lee el Input, construye los
comandos, llama a `sim.advance()`, y luego pide a las views que se dibujen. **El Input solo se lee
acá, nunca dentro de la simulación.**

- [ ] **Step 1: Implementar SimDriver**

`scripts/render/sim_driver.gd`:
```gdscript
class_name SimDriver
extends Node

@export var view1_path: NodePath
@export var view2_path: NodePath

const TICK_DELTA := 1.0 / SimConstants.TICK_HZ

var _sim: Simulation
var _view1: FighterView
var _view2: FighterView
var _accumulator := 0.0

# Mapeo de acciones de input por jugador.
const P1_ACTIONS := {
	SimConstants.BTN_LEFT: "left",
	SimConstants.BTN_RIGHT: "right",
	SimConstants.BTN_JUMP: "jump",
	SimConstants.BTN_ATTACK: "attack",
}
const P2_ACTIONS := {
	SimConstants.BTN_LEFT: "left_p2",
	SimConstants.BTN_RIGHT: "right_p2",
	SimConstants.BTN_JUMP: "jump_p2",
	SimConstants.BTN_ATTACK: "attack_p2",
}

func _ready() -> void:
	_view1 = get_node(view1_path)
	_view2 = get_node(view2_path)
	var state := SimState.new(2)
	state.fighters[0].pos_x = -300 * SimConstants.SUBPIXEL
	state.fighters[0].pos_y = SimConstants.FLOOR_Y
	state.fighters[1].pos_x = 328 * SimConstants.SUBPIXEL
	state.fighters[1].pos_y = SimConstants.FLOOR_Y
	_sim = Simulation.new(state)

func _read_command(actions: Dictionary) -> InputCommand:
	var cmd := InputCommand.new()
	for bit in actions:
		if Input.is_action_pressed(actions[bit]):
			cmd.set_held(bit, true)
	return cmd

func _process(delta: float) -> void:
	# Paso fijo: la simulación avanza en ticks de 1/60 s exactos.
	_accumulator += delta
	while _accumulator >= TICK_DELTA:
		var commands := [_read_command(P1_ACTIONS), _read_command(P2_ACTIONS)]
		_sim.advance(commands)
		_accumulator -= TICK_DELTA
	# Render con el estado más reciente.
	_view1.render_state(_sim.state.fighters[0])
	_view2.render_state(_sim.state.fighters[1])
```

- [ ] **Step 2: Editar `scenes/main.tscn`**

En el editor de Godot (o editando el `.tscn`):
1. Cambiar el script de `Fighter1` y `Fighter2` de `res://scripts/fighter.gd` a
   `res://scripts/render/fighter_view.gd`. Mantener el hijo `AnimatedSprite2D`.
2. Quitar las `@export` viejas de los fighters (`opponent`, `left_action`, etc.) ya no usadas.
3. Agregar un nodo `SimDriver` (type `Node`) hijo de `Main` con script `sim_driver.gd`, y setear
   `view1_path = ../Fighter1`, `view2_path = ../Fighter2`.
4. El nodo `UI` (`ui.gd`) lee `fighter.dead`/`fighter.health`: se deja temporalmente roto o se
   comenta su `_process`; la barra de vida real se reconecta al estado de la sim en Spec 02/04.

- [ ] **Step 3: Verificación manual (correr el juego)**

Run: abrir el proyecto en Godot y darle Play a `main.tscn` (o `godot res://scenes/main.tscn`),
o usar el Godot MCP para lanzar la escena.
Expected:
- Los dos luchadores caen al suelo y se quedan en reposo (gravedad determinista funciona).
- P1 (A/D/W/F) y P2 (J/L/I/H) se mueven, saltan y muestran la animación de ataque.
- Se miran entre sí (facing correcto).
- No hay errores en consola sobre `Input` dentro de la simulación.

- [ ] **Step 4: Commit**

```bash
git add scripts/render/sim_driver.gd scenes/main.tscn
git commit -m "feat: drive sim from fixed-step SimDriver, decouple render (Spec 01)"
```

---

## Task 9: Limpieza y cierre del spec

**Files:**
- Modify: `docs/PROGRESS.md`
- Modify: `docs/DECISIONS.md`
- Modify: `docs/LESSONS.md` (si hubo errores)

- [ ] **Step 1: Registrar el ADR de punto fijo**

Agregar a `docs/DECISIONS.md`:
```markdown
## ADR-006 — Matemática de simulación en enteros (punto fijo, subpíxeles)
- **Fecha:** 2026-06-15 · **Estado:** aceptada
- **Contexto:** El float IEEE-754 puede divergir entre máquinas y rompería el rollback.
- **Decisión:** Posiciones/velocidades/aceleraciones en enteros, 1 px = 1000 subunidades.
- **Consecuencias:** Determinismo garantizado en el movimiento; el render divide por SUBPIXEL.
```

- [ ] **Step 2: Actualizar PROGRESS.md**

Marcar Spec 01 como ✅ con nota: "Simulación determinista: paso fijo 60Hz, InputCommand, RNG
sembrado, SimState con serialize/checksum, Simulation.advance, render desacoplado (FighterView),
SimDriver. Tests de replay y rollback verdes." Agregar entrada de bitácora con la fecha.

- [ ] **Step 3: Correr toda la batería de tests una última vez**

Run: `godot --headless --script res://tests/test_runner.gd`
Expected: todos `PASS`, `Total failures: 0`, exit code 0.

- [ ] **Step 4: Commit final**

```bash
git add docs/
git commit -m "docs: close Spec 01 (deterministic sim) — ADR-006, progress, tests green"
```

---

## Notas para quien ejecute

- **Ruta de Godot:** si `godot` no está en el PATH de Windows, reemplazar por la ruta completa del
  ejecutable de Godot 4.4 (p.ej. `& "C:\ruta\Godot_v4.4.exe" --headless --script ...`) o usar el
  Godot MCP para correr escenas y tests.
- **No introducir float en la simulación.** Si en algún momento aparece la tentación, parar y
  reconsiderar; es la causa #1 de desyncs. Correr `determinism-check`.
- **El UI (`ui.gd`) queda temporalmente desconectado** del modelo; se reconecta en Spec 02/04
  cuando la vida y el combate vivan en el estado de la simulación.
