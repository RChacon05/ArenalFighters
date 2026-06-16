class_name SimDriver
extends Node

@export var view1_path: NodePath
@export var view2_path: NodePath

const TICK_DELTA := 1.0 / SimConstants.TICK_HZ

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

var _sim: Simulation
var _view1: FighterView
var _view2: FighterView
var _accumulator := 0.0

func _ready() -> void:
	_view1 = get_node(view1_path)
	_view2 = get_node(view2_path)
	var s := SimState.new(2)
	s.fighters[0].pos_x = -300 * SimConstants.SUBPIXEL
	s.fighters[0].pos_y = SimConstants.FLOOR_Y
	s.fighters[1].pos_x = 328 * SimConstants.SUBPIXEL
	s.fighters[1].pos_y = SimConstants.FLOOR_Y
	_sim = Simulation.new(s)

func _read_command(actions: Dictionary) -> InputCommand:
	var cmd := InputCommand.new()
	for bit in actions:
		if Input.is_action_pressed(actions[bit]):
			cmd.set_held(bit, true)
	return cmd

func _process(delta: float) -> void:
	_accumulator += delta
	while _accumulator >= TICK_DELTA:
		var commands := [_read_command(P1_ACTIONS), _read_command(P2_ACTIONS)]
		_sim.advance(commands)
		_accumulator -= TICK_DELTA
	_view1.render_state(_sim.state.fighters[0])
	_view2.render_state(_sim.state.fighters[1])
