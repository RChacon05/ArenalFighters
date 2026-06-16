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
