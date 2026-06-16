extends CharacterBody2D

enum State {
	IDLE,
	WALK,
	JUMP,
	ATTACK,
	HIT,
	BLOCK,
	DEAD
}
var current_state = State.IDLE

@export var left_action := "left"
@export var right_action := "right"
@export var jump_action := "jump"
@export var attack_action := "attack"
@export var opponent: Node2D
@export var fighter_data: FighterData

var health: int = 100
var SPEED: float = 300.0
var JUMP_VELOCITY: float = -500.0
var knockback_force: float = 150.0
var attack_timer: int = 0
var hitstun_timer: int = 0

var attacking: bool = false
var stunned: bool = false
var dead: bool = false
var last_state: int = -1
var blocking: bool = false
var blockstun_timer: int = 0

func _ready() -> void:
	if fighter_data:
		health = fighter_data.max_health
		SPEED = fighter_data.walk_speed
		JUMP_VELOCITY = fighter_data.jump_velocity
		knockback_force = fighter_data.knockback_force

func update_facing():
	if opponent == null:
		return
	if global_position.x < opponent.global_position.x:
		$AnimatedSprite2D.flip_h = false
		$Hitbox.scale.x = 1
	else:
		$AnimatedSprite2D.flip_h = true
		$Hitbox.scale.x = -1

func update_animation():

	if current_state == last_state:
		return

	last_state = current_state

	match current_state:

		State.IDLE:
			$AnimatedSprite2D.play("idle")

		State.WALK:
			$AnimatedSprite2D.play("walk")

		State.JUMP:
			$AnimatedSprite2D.play("jump")

		State.ATTACK:
			$AnimatedSprite2D.play("attack")

		State.HIT:
			$AnimatedSprite2D.play("hit")

		State.BLOCK:
			$AnimatedSprite2D.play("idle")

		State.DEAD:
			$AnimatedSprite2D.play("death")

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

func die():
	print(name + " muerto")
	dead = true
	current_state = State.DEAD
	$AnimatedSprite2D.offset.y = 200
	$AnimatedSprite2D.play("death")

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

func attack() -> void:
	if attacking or hitstun_timer > 0 or blockstun_timer > 0 or dead:
		return
	attacking = true
	attack_timer = 0

func enable_hitbox():
	$Hitbox.monitoring = true

func disable_hitbox():
	$Hitbox.monitoring = false

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

func is_blocking_input() -> bool:
	if opponent == null:
		return false
	var dir: float = Input.get_axis(left_action, right_action)
	var facing_right: bool = opponent.global_position.x > global_position.x
	return (facing_right and dir < -0.5) or (not facing_right and dir > 0.5)

func _physics_process(delta: float) -> void:
	if not dead:
		# Attack frame counter: startup → active → recovery
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

		if blockstun_timer > 0:
			blockstun_timer -= 1

		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed(jump_action) and is_on_floor() and not stunned:
			velocity.y = JUMP_VELOCITY

		if Input.is_action_just_pressed(attack_action):
			attack()

		# Get the input direction and handle the movement/deceleration.
		if not stunned and blockstun_timer == 0:
			var direction: float = Input.get_axis(left_action, right_action)
			if direction:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)

		update_facing()
		update_state()
		update_animation()
		move_and_slide()
