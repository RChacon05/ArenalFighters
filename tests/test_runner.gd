extends SceneTree

const TEST_SCRIPTS := [
	"res://tests/test_smoke.gd",
	"res://tests/test_input_command.gd",
	"res://tests/test_rng.gd",
]

func _initialize() -> void:
	var total_failures := 0
	for path in TEST_SCRIPTS:
		var script: GDScript = load(path)
		var test: SimTestCase = script.new()
		test.run()
		if test.failures.is_empty():
			print("PASS  ", path)
		else:
			for f in test.failures:
				print("FAIL  ", path, " :: ", f)
			total_failures += test.failures.size()
	print("---")
	print("Total failures: ", total_failures)
	quit(0 if total_failures == 0 else 1)
