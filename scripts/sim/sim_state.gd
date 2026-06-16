class_name SimState
extends RefCounted

var tick: int = 0
var fighters: Array[FighterState] = []
var rng_state: int = 1

func _init(fighter_count: int = 2) -> void:
	for i in range(fighter_count):
		fighters.append(FighterState.new())

func clone() -> SimState:
	var s := SimState.new(0)
	s.tick = tick
	s.rng_state = rng_state
	for f in fighters:
		s.fighters.append(f.clone())
	return s

func _flatten() -> PackedInt64Array:
	var out := PackedInt64Array()
	out.append(tick)
	out.append(rng_state)
	out.append(fighters.size())
	for f in fighters:
		for n in f.to_ints():
			out.append(n)
	return out

func serialize() -> PackedByteArray:
	return _flatten().to_byte_array()

static func deserialize(bytes: PackedByteArray) -> SimState:
	var ints := bytes.to_int64_array()
	var s := SimState.new(0)
	s.tick = ints[0]
	s.rng_state = ints[1]
	var count := ints[2]
	var idx := 3
	for i in range(count):
		var f := FighterState.new()
		f.from_ints(ints.slice(idx, idx + FighterState.FIELD_COUNT))
		s.fighters.append(f)
		idx += FighterState.FIELD_COUNT
	return s

func checksum() -> int:
	var bytes := serialize()
	var h := 2166136261
	for b in bytes:
		h = (h ^ b) & 0xFFFFFFFF
		h = (h * 16777619) & 0xFFFFFFFF
	return h
