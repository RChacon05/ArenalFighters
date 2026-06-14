extends Camera2D

@export var fighter1: Node2D
@export var fighter2: Node2D

@export var ground_y := 450.0
@export var ground_screen_ratio := 0.8

@export var side_margin := 150.0
@export var min_view_width := 500.0
@export var zoom_speed := 5.0
@export var move_speed := 8.0

func _physics_process(delta: float) -> void:
	if fighter1 == null or fighter2 == null:
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	var viewport_width: float = viewport_size.x
	var viewport_height: float = viewport_size.y

	var distance: float = absf(fighter1.global_position.x - fighter2.global_position.x)
	var desired_width: float = distance + side_margin * 2.0
	desired_width = maxf(desired_width, min_view_width)

	var target_zoom: float = viewport_width / desired_width
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), zoom_speed * delta)

	var center_x: float = (fighter1.global_position.x + fighter2.global_position.x) * 0.5
	var view_height: float = viewport_height / zoom.y
	var camera_y: float = ground_y - (ground_screen_ratio - 0.5) * view_height

	global_position.x = lerpf(global_position.x, center_x, move_speed * delta)
	global_position.y = camera_y
