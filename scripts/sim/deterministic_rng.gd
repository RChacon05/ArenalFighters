class_name DeterministicRng
extends RefCounted

var state: int

func _init(seed: int = 1) -> void:
	state = seed if seed != 0 else 0x1E3779B97F4A7C15

func next_int() -> int:
	state ^= state << 13
	state ^= state >> 7
	state ^= state << 17
	return state

func next_range(n: int) -> int:
	if n <= 0:
		return 0
	var v := next_int()
	if v < 0:
		v = -v
	return v % n
