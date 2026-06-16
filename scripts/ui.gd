extends CanvasLayer

@export var fighter1 : Node
@export var fighter2 : Node

@onready var bar1 = $TopBar/HealthBarP1
@onready var bar2 = $TopBar/HealthBarP2
@onready var winner_label = $TopBar/WinnerLabel

# UI temporarily disconnected from the simulation state. The old fighter.gd
# exposed `dead` and `health` directly; the new sim keeps that in FighterState
# and the wiring is re-established in Spec 02/04 (health) and Spec 04 (KO).
func _process(_delta: float) -> void:
	pass
