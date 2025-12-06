extends Area2D

@export var next_level_path: String = "res://Scenes/Levels/sample_level_02.tscn"

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		# call_deferred waits for the physics step to complete before changing the sceen.
		get_tree().call_deferred("change_scene_to_file", next_level_path)
