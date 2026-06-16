class_name SimTestCase
extends RefCounted

var failures: Array[String] = []

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s (esperado %s, obtuvo %s)" % [message, str(expected), str(actual)])

func run() -> void:
	pass
