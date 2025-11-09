class_name TutorialUI
extends CanvasLayer

const CONTROL_ICONS = {
	"WalkSign": [
		preload("res://Assets/ui_icon_pack/resources/keyboard/icon_A_key.tres"),
		preload("res://Assets/ui_icon_pack/resources/keyboard/icon_D_key.tres")
	], 
	"JumpSign": [
		preload("res://Assets/ui_icon_pack/resources/keyboard/icon_W_key.tres"),
		preload("res://Assets/ui_icon_pack/resources/keyboard/icon_Space_key.tres")
	], 
	"OrbSign": [
		preload("res://Assets/ui_icon_pack/resources/keyboard/icon_Interact.tres")
	] 
}

@onready var prompt_container: HBoxContainer = $PromptContainer

func _ready() -> void:
	prompt_container.visible = false

func show_prompt(sign_key: String, sign_global_position: Vector2) -> void:
	for child in prompt_container.get_children():
		child.queue_free()

	if CONTROL_ICONS.has(sign_key):
		
		var icons_to_load: Array = CONTROL_ICONS[sign_key]
		
		for icon_texture: Texture in icons_to_load:
			var icon_node: TextureRect = TextureRect.new()
			icon_node.texture = icon_texture
			prompt_container.add_child(icon_node)
			
		prompt_container.global_position = sign_global_position + Vector2(0, -64) 
		prompt_container.visible = true
	else:
		print("TUTORIAL UI ERROR: No icon found for sign key: %s" % sign_key)

func hide_prompt() -> void:
	prompt_container.visible = false
	for child in prompt_container.get_children():
		child.queue_free()
