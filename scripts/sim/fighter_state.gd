class_name FighterState
extends RefCounted

const FIELD_COUNT := 10

var pos_x: int = 0
var pos_y: int = 0
var vel_x: int = 0
var vel_y: int = 0
var facing: int = 1
var state: int = SimConstants.State.IDLE
var state_timer: int = 0
var health: int = 100
var on_floor: bool = false
var prev_buttons: int = 0

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

func to_ints() -> Array[int]:
	return [pos_x, pos_y, vel_x, vel_y, facing, state, state_timer,
			health, 1 if on_floor else 0, prev_buttons]

func from_ints(v: Array) -> void:
	pos_x = v[0]; pos_y = v[1]; vel_x = v[2]; vel_y = v[3]
	facing = v[4]; state = v[5]; state_timer = v[6]
	health = v[7]; on_floor = v[8] != 0; prev_buttons = v[9]
