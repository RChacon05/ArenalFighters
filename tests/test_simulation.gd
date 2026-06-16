extends SimTestCase

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
	check(a[a.size() - 1] != a[0], "el estado cambia a lo largo de la simulación")
