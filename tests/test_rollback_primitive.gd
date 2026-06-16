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

	for t in range(10):
		sim.advance(_commands(t))
	var snapshot := sim.state.serialize()

	for t in range(10, 20):
		sim.advance(_commands(t))
	var expected := sim.state.checksum()

	sim.state = SimState.deserialize(snapshot)
	for t in range(10, 20):
		sim.advance(_commands(t))

	eq(sim.state.checksum(), expected, "resimular tras restaurar da el mismo estado (rollback)")
