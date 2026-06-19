# Spec 01 — Luchador Base Mejorado: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend `fighter.gd` with frame-data-driven attacks, blocking, hitstun, and per-character data resources — without rewriting the working base.

**Architecture:** Create two Resource classes (`MoveData`, `FighterData`) that hold all character-specific data; update `fighter.gd` to read from them and use integer frame counters (each count = one `_physics_process` tick at 60 Hz) instead of AnimationPlayer timers for combat logic; assign distinct `.tres` files per fighter in `main.tscn`.

**Tech Stack:** Godot 4.4 · GDScript · CharacterBody2D · Resource (.tres) · `_physics_process` at 60 Hz (fixed tick)

---

## File Map

| Action | File | Responsibility |
|---|---|---|
| Create | `scripts/move_data.gd` | Resource: frame data for one attack move |
| Create | `scripts/fighter_data.gd` | Resource: character stats + one move slot |
| Create | `data/characters/fighter_a.tres` | Data instance for Fighter A |
| Create | `data/characters/fighter_b.tres` | Data instance for Fighter B |
| Modify | `scripts/fighter.gd` | Read FighterData; frame counters; blocking |
| Modify | `scenes/main.tscn` | Assign .tres to each fighter instance |

---

## Task 1: MoveData resource class

**Files:**
- Create: `scripts/move_data.gd`

- [ ] **Step 1.1 — Create the file**

```gdscript
# scripts/move_data.gd
class_name MoveData
extends Resource

@export var move_name: String = ""
@export var startup_frames: int = 5
@export var active_frames: int = 3
@export var recovery_frames: int = 12
@export var damage: int = 10
@export var hitstun_frames: int = 15
@export var blockstun_frames: int = 8
@export var knockback: float = 150.0
@export var hitbox_offset: Vector2 = Vector2(50.0, 0.0)
```

- [ ] **Step 1.2 — Verify Godot recognizes the class**

Open the Godot editor. In the FileSystem panel, double-click `scripts/move_data.gd`.
The Script editor opens with no errors in the Output panel.
Confirm: in any Inspector resource picker, "MoveData" appears as a creatable type.

- [ ] **Step 1.3 — Commit**

```
git add scripts/move_data.gd
git commit -m "feat(spec01): add MoveData resource class with frame data fields"
```

---

## Task 2: FighterData resource class

**Files:**
- Create: `scripts/fighter_data.gd`

- [ ] **Step 2.1 — Create the file**

```gdscript
# scripts/fighter_data.gd
class_name FighterData
extends Resource

@export var character_name: String = ""
@export var max_health: int = 100
@export var walk_speed: float = 300.0
@export var jump_velocity: float = -500.0
@export var knockback_force: float = 150.0
@export var light_attack: MoveData
```

- [ ] **Step 2.2 — Verify in Godot**

Open Godot editor. In the FileSystem panel, double-click `scripts/fighter_data.gd`.
No errors in Output panel.
In Inspector (any node), if you type "FighterData" in a Resource picker, it should appear as a valid type showing all fields including `light_attack` (which accepts a MoveData sub-resource).

- [ ] **Step 2.3 — Commit**

```
git add scripts/fighter_data.gd
git commit -m "feat(spec01): add FighterData resource class with stats and move slot"
```

---

## Task 3: Data files for Fighter A and Fighter B

**Files:**
- Create: `data/characters/fighter_a.tres`
- Create: `data/characters/fighter_b.tres`

- [ ] **Step 3.1 — Create the data directory**

In the Godot FileSystem panel, right-click `res://` → New Folder → type `data`.
Inside `data`, right-click → New Folder → type `characters`.

(Alternatively: create the OS folders manually; Godot will pick them up on next scan.)

- [ ] **Step 3.2 — Create fighter_a.tres**

In Godot FileSystem panel, right-click `res://data/characters/` → New Resource.
Search "FighterData" → select it → click Create.
Save as `res://data/characters/fighter_a.tres`.

In the Inspector set:
- `character_name` = `"Fighter A"`
- `max_health` = `100`
- `walk_speed` = `300.0`
- `jump_velocity` = `-500.0`
- `knockback_force` = `150.0`
- `light_attack` → click the empty field → New MoveData, then set:
  - `move_name` = `"light_attack"`
  - `startup_frames` = `5`
  - `active_frames` = `3`
  - `recovery_frames` = `12`
  - `damage` = `10`
  - `hitstun_frames` = `15`
  - `blockstun_frames` = `8`
  - `knockback` = `150.0`
  - `hitbox_offset` = `Vector2(50, 0)`

Save (Ctrl+S).

- [ ] **Step 3.3 — Create fighter_b.tres**

Same process. Right-click `res://data/characters/` → New Resource → FighterData → Create.
Save as `res://data/characters/fighter_b.tres`.

In the Inspector set:
- `character_name` = `"Fighter B"`
- `max_health` = `100`
- `walk_speed` = `280.0`
- `jump_velocity` = `-520.0`
- `knockback_force` = `180.0`
- `light_attack` → New MoveData:
  - `move_name` = `"light_attack"`
  - `startup_frames` = `7`
  - `active_frames` = `4`
  - `recovery_frames` = `14`
  - `damage` = `13`
  - `hitstun_frames` = `18`
  - `blockstun_frames` = `10`
  - `knockback` = `180.0`
  - `hitbox_offset` = `Vector2(50, 0)`

Save (Ctrl+S).

- [ ] **Step 3.4 — Commit**

```
git add data/
git commit -m "feat(spec01): add fighter_a and fighter_b .tres data files"
```

---

## Task 4: Update fighter.gd — stats from FighterData + frame-counter attack

**Files:**
- Modify: `scripts/fighter.gd`

Replaces hardcoded stats and AnimationPlayer-based attack logic with FighterData-driven stats and integer frame counters. The `stunned` check in `take_damage()` is removed intentionally — it was preventing combo hits from registering; the hitstun_timer reset on each new hit is the correct mechanic.

- [ ] **Step 4.1 — Replace the export vars block at the top**

Current block (lines ~12–18):
```gdscript
@export var left_action := "left"
@export var right_action := "right"
@export var jump_action := "jump"
@export var attack_action := "attack"
@export var opponent : Node2D
@export var SPEED := 300.0
@export var JUMP_VELOCITY := -500.0
@export var knockback_force := 150.0
@export var health = 100
```

Replace with:
```gdscript
@export var left_action: String = "left"
@export var right_action: String = "right"
@export var jump_action: String = "jump"
@export var attack_action: String = "attack"
@export var opponent: Node2D
@export var fighter_data: FighterData

var health: int = 100
var SPEED: float = 300.0
var JUMP_VELOCITY: float = -500.0
var knockback_force: float = 150.0
var attack_timer: int = 0
var hitstun_timer: int = 0
```

Keep the existing lines below: `var attacking`, `var stunned`, `var dead`, `var last_state`.

- [ ] **Step 4.2 — Add _ready() after the variable block**

Insert this function before `update_facing()`:
```gdscript
func _ready() -> void:
    if fighter_data:
        health = fighter_data.max_health
        SPEED = fighter_data.walk_speed
        JUMP_VELOCITY = fighter_data.jump_velocity
        knockback_force = fighter_data.knockback_force
```

- [ ] **Step 4.3 — Update update_state() to use hitstun_timer instead of stunned**

Replace current `update_state()`:
```gdscript
func update_state() -> void:
    if dead:
        current_state = State.DEAD
    elif hitstun_timer > 0:
        current_state = State.HIT
    elif attacking:
        current_state = State.ATTACK
    elif not is_on_floor():
        current_state = State.JUMP
    elif abs(velocity.x) > 1:
        current_state = State.WALK
    else:
        current_state = State.IDLE
```

- [ ] **Step 4.4 — Add DEAD case to update_animation()**

In `update_animation()`, add this case to the `match` block (it was missing):
```gdscript
State.DEAD:
    $AnimatedSprite2D.play("death")
```

- [ ] **Step 4.5 — Replace attack() with frame-counter version**

Replace current `attack()`:
```gdscript
func attack() -> void:
    if attacking or hitstun_timer > 0 or dead:
        return
    attacking = true
    attack_timer = 0
```

- [ ] **Step 4.6 — Replace take_damage() with frame-counter version**

Replace current `take_damage(amount)`:
```gdscript
func take_damage(amount: int, hit_hitstun: int = 15, hit_blockstun: int = 8) -> void:
    if dead:
        return
    health -= amount
    stunned = true
    hitstun_timer = hit_hitstun
    if opponent:
        var direction: float = sign(global_position.x - opponent.global_position.x)
        velocity.x = direction * knockback_force
    if health <= 0:
        die()
```

Remove the old `hit_finished()` function entirely.
Remove the old `attack_finished()` function entirely.

- [ ] **Step 4.7 — Update _on_hitbox_area_entered to use move data**

Replace current `_on_hitbox_area_entered`:
```gdscript
func _on_hitbox_area_entered(area: Area2D) -> void:
    if dead:
        return
    if area.is_in_group("hurtbox"):
        var fighter: Node = area.get_parent()
        var move: MoveData = fighter_data.light_attack if fighter_data else null
        var dmg: int = move.damage if move else 15
        var hs: int = move.hitstun_frames if move else 15
        var bs: int = move.blockstun_frames if move else 8
        fighter.take_damage(dmg, hs, bs)
```

- [ ] **Step 4.8 — Add frame-counter logic inside _physics_process**

In `_physics_process(delta)`, add these two blocks immediately after the `if not dead:` opening line, before any existing logic:

```gdscript
# Attack frame counter: drives startup / active / recovery phases
if attacking and fighter_data and fighter_data.light_attack:
    attack_timer += 1
    var move: MoveData = fighter_data.light_attack
    var active_end: int = move.startup_frames + move.active_frames
    var total: int = active_end + move.recovery_frames
    if attack_timer == move.startup_frames:
        enable_hitbox()
        if opponent:
            var facing: float = sign(opponent.global_position.x - global_position.x)
            $Hitbox.position.x = move.hitbox_offset.x * facing
    elif attack_timer == active_end:
        disable_hitbox()
    elif attack_timer >= total:
        attacking = false
        attack_timer = 0

# Hitstun frame counter
if hitstun_timer > 0:
    hitstun_timer -= 1
    if hitstun_timer == 0:
        stunned = false
```

Also remove any remaining `$AnimationPlayer.play("attack_logic")` or `$AnimationPlayer.play("hit_logic")` calls if they still appear elsewhere in the file.

- [ ] **Step 4.9 — Run the game and verify**

Open Godot. Run the project (F5 or the Play button).
Expected observations:
- Fighters load and move normally.
- Pressing attack triggers the attack animation with a brief delay before the hitbox fires (startup frames).
- The hitbox deactivates after active frames.
- After a hit, the enemy is frozen for hitstun_timer frames, then recovers.
- Health decrements by the values from the .tres (if wired up) or by 15 (fallback).
- At 0 HP, the death animation plays.

- [ ] **Step 4.10 — Commit**

```
git add scripts/fighter.gd
git commit -m "feat(spec01): replace AnimationPlayer timers with integer frame counters for attack and hitstun"
```

---

## Task 5: Add blocking and blockstun

**Files:**
- Modify: `scripts/fighter.gd`

- [ ] **Step 5.1 — Add BLOCK to the State enum**

In the `enum State` block, add `BLOCK`:
```gdscript
enum State {
    IDLE,
    WALK,
    JUMP,
    ATTACK,
    HIT,
    BLOCK,
    DEAD
}
```

- [ ] **Step 5.2 — Add blocking variables**

After the existing `var dead` and `var last_state` lines, add:
```gdscript
var blocking: bool = false
var blockstun_timer: int = 0
```

- [ ] **Step 5.3 — Add is_blocking_input() helper**

Add this function before `_physics_process`:
```gdscript
func is_blocking_input() -> bool:
    if opponent == null:
        return false
    var dir: float = Input.get_axis(left_action, right_action)
    var facing_right: bool = opponent.global_position.x > global_position.x
    return (facing_right and dir < -0.5) or (not facing_right and dir > 0.5)
```

- [ ] **Step 5.4 — Update update_state() to include BLOCK**

Replace the `update_state()` from Task 4 with:
```gdscript
func update_state() -> void:
    if dead:
        current_state = State.DEAD
    elif hitstun_timer > 0:
        current_state = State.HIT
    elif blockstun_timer > 0:
        current_state = State.BLOCK
    elif attacking:
        current_state = State.ATTACK
    elif not is_on_floor():
        current_state = State.JUMP
    elif is_blocking_input():
        blocking = true
        current_state = State.BLOCK
    elif abs(velocity.x) > 1:
        blocking = false
        current_state = State.WALK
    else:
        blocking = false
        current_state = State.IDLE
```

- [ ] **Step 5.5 — Add BLOCK case to update_animation()**

In `update_animation()`, add:
```gdscript
State.BLOCK:
    $AnimatedSprite2D.play("idle")
```

(Uses idle animation as placeholder until a dedicated block animation is added in Spec 08.)

- [ ] **Step 5.6 — Update take_damage() to check blocking**

Replace `take_damage()` from Task 4 with:
```gdscript
func take_damage(amount: int, hit_hitstun: int = 15, hit_blockstun: int = 8) -> void:
    if dead:
        return
    if blocking:
        blockstun_timer = hit_blockstun
        return
    health -= amount
    stunned = true
    hitstun_timer = hit_hitstun
    if opponent:
        var direction: float = sign(global_position.x - opponent.global_position.x)
        velocity.x = direction * knockback_force
    if health <= 0:
        die()
```

- [ ] **Step 5.7 — Add blockstun counter in _physics_process**

In `_physics_process`, add this block right after the hitstun counter block:
```gdscript
# Blockstun frame counter
if blockstun_timer > 0:
    blockstun_timer -= 1
```

- [ ] **Step 5.8 — Prevent attack during blockstun**

Replace the `attack()` from Task 4 with:
```gdscript
func attack() -> void:
    if attacking or hitstun_timer > 0 or blockstun_timer > 0 or dead:
        return
    attacking = true
    attack_timer = 0
```

- [ ] **Step 5.9 — Prevent movement during blockstun and hitstun**

In `_physics_process`, find the movement direction block:
```gdscript
if not stunned:
    var direction := Input.get_axis(left_action, right_action)
    ...
```

Replace with:
```gdscript
if not stunned and blockstun_timer == 0:
    var direction: float = Input.get_axis(left_action, right_action)
    if direction:
        velocity.x = direction * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
```

- [ ] **Step 5.10 — Run and verify blocking**

Open Godot. Run (F5).
Expected:
- When a fighter holds the direction away from the opponent and the opponent attacks, they take NO damage and are briefly frozen (blockstun frames).
- After blockstun ends, the fighter can move and attack normally.
- You cannot attack while in blockstun (button press is ignored).

- [ ] **Step 5.11 — Commit**

```
git add scripts/fighter.gd
git commit -m "feat(spec01): add blocking state and blockstun frame counter"
```

---

## Task 6: Wire FighterData into main.tscn

**Files:**
- Modify: `scenes/main.tscn`

- [ ] **Step 6.1 — Open main.tscn in Godot**

In Godot, open `scenes/main.tscn`.

- [ ] **Step 6.2 — Assign fighter_a.tres to Player 1**

Select the Player 1 fighter node in the scene tree.
In the Inspector, find the `Fighter Data` field (exposed from `@export var fighter_data: FighterData`).
Click the empty field → Load → navigate to `res://data/characters/fighter_a.tres` → Open.

- [ ] **Step 6.3 — Assign fighter_b.tres to Player 2**

Select the Player 2 fighter node.
In the Inspector → `Fighter Data` field → Load → `res://data/characters/fighter_b.tres`.

Save the scene (Ctrl+S).

- [ ] **Step 6.4 — Verify data-driven behavior**

Run (F5). Expected:
- Fighter A loads with 300 walk speed, 100 HP, light attack dealing 10 damage with 5-frame startup.
- Fighter B loads with 280 walk speed, 100 HP, light attack dealing 13 damage with 7-frame startup (slightly slower).
- To spot the startup difference: both fighters are standing still, then press attack — Fighter A's hitbox fires slightly sooner than Fighter B's.

- [ ] **Step 6.5 — Commit**

```
git add scenes/main.tscn
git commit -m "feat(spec01): assign FighterData .tres resources to fighter instances in main.tscn"
```

---

## Self-Review

**Spec 01 coverage check:**

| Requirement | Covered by |
|---|---|
| Frame data (startup/active/recovery) | Tasks 1, 4 |
| Hitbox data-driven (damage, offset) | Tasks 1, 4 step 4.7–4.8 |
| Hitstun | Tasks 1, 4 |
| Blocking + blockstun | Task 5 |
| Knockback (data-driven) | Tasks 1, 4 step 4.6 |
| FighterData .tres per personaje | Tasks 2, 3, 6 |
| Mantiene Input directo | All tasks — `Input.is_action_*` preserved |
| Mantiene move_and_slide() + delta | All tasks — physics block unchanged |

**Placeholder scan:** None found. All steps have concrete code.

**Type consistency check:** `MoveData` (Task 1) is used in `FighterData` (Task 2) and in `fighter.gd` (Tasks 4–5). Field names are consistent: `startup_frames`, `active_frames`, `recovery_frames`, `damage`, `hitstun_frames`, `blockstun_frames`, `knockback`, `hitbox_offset` — used identically across all tasks.
