extends Control

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UserInterface/main_menu.tscn")
