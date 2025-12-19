extends Area2D

# Portal configuration
@export var required_orbs: int = 2
@export var next_scene_path: String = ""
@export var bad_ending_scene_path: String = ""
@export var good_ending_scene_path: String = ""

# Prompt text
@export var ready_text: String = "Press E to enter portal"
@export var need_orbs_text: String = "Need %d orbs"

# Visual styling (matching sign system)
var pixel_font: Font = preload("res://Fonts/PixelOperator.ttf")
@export var base_scale: float = 1.0
@export var bg_color: Color = Color(0.85, 0.85, 0.85, 0.85)
@export var font_px: int = 16
@export var pad_x: float = 6.0
@export var pad_y: float = 4.0

# Internal state
var player_in_range: bool = false
var player_node: Node = null
var prompt: Node2D = null

func _ready() -> void:	
	# Create the prompt node
	prompt = Node2D.new()
	prompt.name = "Prompt"
	prompt.visible = false
	add_child(prompt)

func _process(_delta: float) -> void:
	if player_in_range:
		# Update prompt text dynamically
		_update_prompt()
		
		# Check for enter input
		if Input.is_action_just_pressed("ui_accept"):
			_try_enter_portal()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		player_node = body
		prompt.visible = true
		_update_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		player_node = null
		prompt.visible = false

func _update_prompt() -> void:
	var orbs_collected: int = _get_player_orbs()
	var text: String = ""
	
	if orbs_collected >= required_orbs:
		text = ready_text
	else:
		var needed: int = required_orbs - orbs_collected
		text = need_orbs_text % needed
	
	_render_prompt(text)

func _render_prompt(text: String) -> void:
	# Clear old prompt
	for c: Node in prompt.get_children():
		c.queue_free()
	
	# Create background
	var bg: ColorRect = ColorRect.new()
	bg.color = bg_color
	prompt.add_child(bg)
	
	# Create label
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_override("font", pixel_font)
	label.add_theme_font_size_override("font_size", font_px)
	label.add_theme_color_override("font_color", Color(0.12, 0.12, 0.12))
	prompt.add_child(label)
	
	# Measure text and size background
	var text_size: Vector2 = pixel_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_px)
	var total_w: float = text_size.x + pad_x * 2.0
	var total_h: float = text_size.y + pad_y * 2.0
	
	bg.position = Vector2(-pad_x, -pad_y)
	bg.size = Vector2(total_w, total_h)
	
	# Center the prompt horizontally
	var shift_x: float = -(total_w * 0.5)
	bg.position.x = shift_x
	label.position.x = shift_x + pad_x
	label.position.y = -pad_y
	
	prompt.scale = Vector2.ONE * base_scale
	
	# Position prompt above portal
	prompt.position = Vector2(0, -40)

func _try_enter_portal() -> void:
	var orbs_collected: int = _get_player_orbs()
	
	if orbs_collected < required_orbs:
		_show_insufficient_orbs_feedback()
		return
	
	var scene_to_load: String = ""
	
	if bad_ending_scene_path != "" and good_ending_scene_path != "":
		var total_orbs: int = _get_total_orbs_in_level()
		if orbs_collected >= total_orbs:
			scene_to_load = good_ending_scene_path
		else:
			scene_to_load = bad_ending_scene_path
	else:
		scene_to_load = next_scene_path
	
	if scene_to_load != "":
		get_tree().change_scene_to_file(scene_to_load)
	else:
		push_error("Portal: No scene path configured!")

func _get_player_orbs() -> int:
	if has_node("/root/GameManager"):
		var game_manager: Node = get_node("/root/GameManager")
		if game_manager.has_method("get_orbs_collected"):
			return game_manager.get_orbs_collected()
	
	if player_node and player_node.has_method("get_orbs_collected"):
		return player_node.get_orbs_collected()
	
	if player_node and "orbs_collected" in player_node:
		return player_node.get("orbs_collected")
	
	# Try to get from OrbLabel
	var orb_label: Node = get_tree().current_scene.get_node_or_null("Ui/OrbLabel")
	if orb_label:
		if orb_label.has_method("get_orb_count"):
			return orb_label.get_orb_count()
		if "orb_count" in orb_label:
			return orb_label.get("orb_count")
	
	return 0

func _get_total_orbs_in_level() -> int:
	var orbs: Array = get_tree().get_nodes_in_group("orb")
	return orbs.size()

func _show_insufficient_orbs_feedback() -> void:
	if prompt:
		var original_color: Color = bg_color
		# Flash red
		for c: Node in prompt.get_children():
			if c is ColorRect:
				(c as ColorRect).color = Color.RED
		await get_tree().create_timer(0.3).timeout
		for c: Node in prompt.get_children():
			if c is ColorRect:
				(c as ColorRect).color = original_color
