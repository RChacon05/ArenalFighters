extends SimTestCase

func run() -> void:
	var a := DeterministicRng.new(12345)
	var b := DeterministicRng.new(12345)
	for i in range(5):
		eq(a.next_int(), b.next_int(), "misma seed produce mismo valor en el paso %d" % i)
	var saved := a.state
	var x := a.next_int()
	a.state = saved
	eq(a.next_int(), x, "restaurar el estado reproduce el mismo valor")
