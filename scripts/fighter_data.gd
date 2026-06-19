# scripts/fighter_data.gd
class_name FighterData
extends Resource

@export var character_name: String = ""
@export var max_health: int = 100
@export var walk_speed: float = 300.0
@export var jump_velocity: float = -500.0
@export var knockback_force: float = 150.0
@export var light_attack: MoveData
