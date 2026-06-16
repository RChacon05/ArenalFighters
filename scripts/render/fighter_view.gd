class_name FighterView
extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const ANIM_BY_STATE := {
	SimConstants.State.IDLE: "idle",
	SimConstants.State.WALK: "walk",
	SimConstants.State.JUMP: "jump",
	SimConstants.State.ATTACK: "attack",
	SimConstants.State.HIT: "hit",
	SimConstants.State.DEAD: "death",
}

func render_state(f: FighterState) -> void:
	position.x = float(f.pos_x) / SimConstants.SUBPIXEL
	position.y = float(f.pos_y) / SimConstants.SUBPIXEL
	sprite.flip_h = f.facing < 0
	var anim: String = ANIM_BY_STATE.get(f.state, "idle")
	if sprite.animation != anim:
		sprite.play(anim)
