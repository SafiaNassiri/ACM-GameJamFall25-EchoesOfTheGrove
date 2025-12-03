extends Node

@export var restart_scene_path: String = "res://Scenes/sample_level_02.tscn"

var _is_dying: bool = false

@onready var body: CharacterBody2D = get_parent() as CharacterBody2D
@onready var sprite: AnimatedSprite2D = get_parent().get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
@onready var anim: AnimationPlayer = get_parent().get_node_or_null("AnimationPlayer") as AnimationPlayer

func die() -> void:
	if _is_dying:
		return
	_is_dying = true

	# stop movement/animation controllers so they don't overwrite "death" animation
	for child in get_parent().get_children():
		if child != self and not (child == sprite or child == anim):
			child.set_process(false)
			child.set_physics_process(false)

	if body:
		body.collision_layer = 0
		body.collision_mask = 0
		if "velocity" in body:
			body.velocity = Vector2.ZERO

	if sprite:
		sprite.play("death")
		await sprite.animation_finished
	elif anim:
		anim.play("death")
		await anim.animation_finished

	get_tree().change_scene_to_file(restart_scene_path)
