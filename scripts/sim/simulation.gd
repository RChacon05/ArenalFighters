class_name Simulation
extends RefCounted

var state: SimState
var rng: DeterministicRng

func _init(initial_state: SimState) -> void:
	state = initial_state
	rng = DeterministicRng.new(state.rng_state if state.rng_state != 0 else 1)

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

	if f.state == SimConstants.State.ATTACK or f.state == SimConstants.State.HIT:
		f.state_timer -= 1
		if f.state_timer <= 0:
			f.state = SimConstants.State.IDLE
	else:
		if (just_pressed & SimConstants.BTN_ATTACK) != 0 and f.on_floor:
			f.state = SimConstants.State.ATTACK
			f.state_timer = SimConstants.ATTACK_TICKS

	var blocked := f.state == SimConstants.State.ATTACK or f.state == SimConstants.State.HIT

	if not blocked:
		var dir := 0
		if cmd.is_held(SimConstants.BTN_LEFT):
			dir -= 1
		if cmd.is_held(SimConstants.BTN_RIGHT):
			dir += 1
		f.vel_x = dir * SimConstants.MOVE_SPEED
	else:
		f.vel_x = 0

	if not blocked and (just_pressed & SimConstants.BTN_JUMP) != 0 and f.on_floor:
		f.vel_y = SimConstants.JUMP_VELOCITY
		f.on_floor = false

	f.vel_y += SimConstants.GRAVITY

	f.pos_x += f.vel_x
	f.pos_y += f.vel_y

	if f.pos_y >= SimConstants.FLOOR_Y:
		f.pos_y = SimConstants.FLOOR_Y
		f.vel_y = 0
		f.on_floor = true

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
