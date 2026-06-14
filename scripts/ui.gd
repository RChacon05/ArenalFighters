extends CanvasLayer

@export var fighter1 : Node
@export var fighter2 : Node

@onready var bar1 = $TopBar/HealthBarP1
@onready var bar2 = $TopBar/HealthBarP2
@onready var winner_label = $TopBar/WinnerLabel

func _process(_delta):

	if fighter1.dead:
		winner_label.text = "Jugador 2 muelto"

	elif fighter2.dead:
		winner_label.text = "Jugador 2 muelto"
	
	if fighter1:
		bar1.value = fighter1.health

	if fighter2:
		bar2.value = fighter2.health
