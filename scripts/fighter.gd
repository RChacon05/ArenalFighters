extends CharacterBody2D

enum State {
	IDLE,
	WALK,
	JUMP,
	ATTACK,
	HIT,
	DEAD
}
var current_state = State.IDLE

@export var left_action := "left"
@export var right_action := "right"
@export var jump_action := "jump"
@export var attack_action := "attack"
@export var opponent : Node2D
@export var SPEED := 300.0
@export var JUMP_VELOCITY := -500.0
@export var knockback_force := 150.0
@export var health = 100

var attacking = false
var stunned = false
var dead = false
var last_state = -1

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

func update_state():

	if dead:
		current_state = State.DEAD

	elif stunned:
		current_state = State.HIT

	elif attacking:
		current_state = State.ATTACK

	elif not is_on_floor():
		current_state = State.JUMP

	elif abs(velocity.x) > 1:
		current_state = State.WALK

	else:
		current_state = State.IDLE

func die():
	print(name + " muelto")
	dead = true
	current_state = State.DEAD
	$AnimatedSprite2D.offset.y = 200
	$AnimatedSprite2D.play("death")

func take_damage(amount):
	if stunned:
		return
		
	health -= amount
	
	current_state = State.HIT
	stunned = true
	
	if opponent:
		var direction = sign(global_position.x - opponent.global_position.x)
		velocity.x = direction * knockback_force
		
	$AnimationPlayer.play("hit_logic")
	
	if health <= 0:
		die()

func hit_finished():
	stunned = false

func attack():
	if attacking:
		return
	
	attacking = true
	
	$AnimatedSprite2D.play("attack")
	$AnimationPlayer.play("attack_logic")
	
func enable_hitbox():
	$Hitbox.monitoring = true

func disable_hitbox():
	$Hitbox.monitoring = false

func attack_finished():
	attacking = false

func _on_hitbox_area_entered(area: Area2D) -> void:
	if not dead:
		if area.is_in_group("hurtbox"):
			var fighter = area.get_parent()
			fighter.take_damage(15)
			print("pum te pego")

func _physics_process(delta: float) -> void:
	if not dead:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed(jump_action) and is_on_floor() and not stunned:
			velocity.y = JUMP_VELOCITY
		
		if Input.is_action_just_pressed(attack_action):
			attack()
		

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		if not stunned:
			var direction := Input.get_axis(left_action, right_action)
			if direction:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)

		update_facing()
		update_state()
		update_animation()
		move_and_slide()
