extends SimTestCase

func run() -> void:
	var s := SimState.new(2)
	s.fighters[0].pos_x = 12345
	s.fighters[1].pos_x = -678
	s.tick = 7

	var c := s.clone()
	c.fighters[0].pos_x = 999
	eq(s.fighters[0].pos_x, 12345, "clone no comparte referencias con el original")

	var bytes := s.serialize()
	var restored := SimState.deserialize(bytes)
	eq(restored.checksum(), s.checksum(), "serialize/deserialize conserva el checksum")
	eq(restored.tick, s.tick, "deserialize conserva el tick")

	var d := s.clone()
	d.fighters[1].pos_x = 4242
	check(d.checksum() != s.checksum(), "estados distintos producen checksums distintos")
