# scripts/move_data.gd
class_name MoveData
extends Resource

@export var move_name: String = ""
@export var startup_frames: int = 5
@export var active_frames: int = 3
@export var recovery_frames: int = 12
@export var damage: int = 10
@export var hitstun_frames: int = 15
@export var blockstun_frames: int = 8
@export var knockback: float = 150.0
@export var hitbox_offset: Vector2 = Vector2(50.0, 0.0)
