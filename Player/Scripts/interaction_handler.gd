extends Area2D

@export var sign_texts: Dictionary[String, String] = {
	"JumpSign": "Press Space to jump",
	"WalkSign": "Use A/D or ←/→ to move",
	"OrbSign": "Collect the orbs"
}

const UI_MANAGER_NAME = "TutorialUIManager"

var orb_count: int = 0

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	body_exited.connect(_on_body_exited)

# === Entry Handlers ===
func _on_area_entered(a: Area2D) -> void:
	_process_hit(a)

func _on_body_entered(b: Node) -> void:
	_process_hit(b)

# === Exit Handlers ===
func _on_area_exited(a: Area2D) -> void:
	_process_exit(a)

func _on_body_exited(b: Node) -> void:
	_process_exit(b)

func _process_exit(n: Node) -> void:
	# Only hide the prompt if a SIGN is exiting
	# FIX: Removed the '... and n.is_in_group("player")' check
	var sign_target: Node = _find_with_group(n, "sign")
	if sign_target:
		if Engine.has_singleton(UI_MANAGER_NAME):
			var ui_manager: TutorialUI = get_node("/root/" + UI_MANAGER_NAME) as TutorialUI
			if ui_manager:
				ui_manager.hide_prompt()

func _process_hit(n: Node) -> void:
	# === Orb Collection Logic ===
	var orb_target: Node = _find_with_group(n, "orb")
	if orb_target:
		orb_count += 1
		orb_target.queue_free()
		print("Orbs: %d" % orb_count)
		if Engine.has_singleton(UI_MANAGER_NAME):
			var ui_manager: TutorialUI = get_node("/root/" + UI_MANAGER_NAME) as TutorialUI
			if ui_manager:
				ui_manager.hide_prompt()
		return
	
	# === Sign trigger Logic ===
	var sign_target: Node = _find_with_group(n, "sign")
	
	# FIX: Removed the '... and n.is_in_group("player")' check.
	# 'n' is the sign itself, not the player.
	if sign_target: 
		
		var target_2d: Node2D = sign_target as Node2D
		if not target_2d:
			print("ERROR: Sign node '%s' is not a Node2D!" % sign_target.name)
			return

		var sign_name: String = target_2d.name
		
		# 1. attempt to display UI icon
		if Engine.has_singleton(UI_MANAGER_NAME):
			var ui_manager: TutorialUI = get_node("/root/" + UI_MANAGER_NAME) as TutorialUI
			
			if ui_manager:
				# Use the sign's position to show the prompt
				ui_manager.show_prompt(sign_name, target_2d.global_position)
			else:
				print("ERROR: Could not cast UI Manager. Did you add 'class_name TutorialUI'?")

		# 2. console fallback
		var msg: String = sign_texts.get(sign_name, sign_name)
		print("TUTORIAL: " + msg)

# === Util funct ===
func _find_with_group(start: Node, group_name: String) -> Node:
	var p: Node = start
	while p:
		if p.is_in_group(group_name):
			return p
		p = p.get_parent()
	return null
