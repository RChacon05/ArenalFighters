extends SimTestCase

func run() -> void:
	var cmd := InputCommand.new()
	cmd.set_held(SimConstants.BTN_LEFT, true)
	cmd.set_held(SimConstants.BTN_ATTACK, true)
	check(cmd.is_held(SimConstants.BTN_LEFT), "LEFT debe estar presionado")
	check(cmd.is_held(SimConstants.BTN_ATTACK), "ATTACK debe estar presionado")
	check(not cmd.is_held(SimConstants.BTN_JUMP), "JUMP no debe estar presionado")
	var packed := cmd.to_int()
	var restored := InputCommand.from_int(packed)
	eq(restored.buttons, cmd.buttons, "serialización round-trip preserva botones")
