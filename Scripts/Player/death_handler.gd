extends Node
class_name DeathHandler

var _is_dying: bool = false

@onready var body: CharacterBody2D = get_parent() as CharacterBody2D
@onready var sprite: AnimatedSprite2D = get_parent().get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
@onready var anim: AnimationPlayer = get_parent().get_node_or_null("AnimationPlayer") as AnimationPlayer

@onready var death_ui: Control = $"../../Ui/DeathUI"
@onready var lore_label: Label = $"../../Ui/DeathUI/Label3" 

# --- UPDATED LORE LIST ---
var lore_lines: Array[String] = [
	"The Hourseed Tree waits for a savior who never came.",
	"Time solidifies around you like amber.",
	"Your flute falls silent in the heavy air.",
	"The stillness claims you, Thistle.",
	"You become another frozen memory in the Everglen.",
	"The world exhales one last breath.",
	"The shattered time remains broken.",
	"Roots grow over your failure.",
	"The forest forgets your name.",
	"The heart of the forest beats no more.",
	"Frozen mid-moment, forever.",
	"The relics lie scattered in the silence."
]

func die() -> void:
	if _is_dying:
		return
	_is_dying = true

	# Stop all other scripts on the player
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
		
	var prev_death_visible: bool = death_ui.visible if death_ui != null else false
	
	if is_instance_valid(death_ui):
		# Pick random text and assign it
		if is_instance_valid(lore_label) and lore_lines.size() > 0:
			lore_label.text = lore_lines.pick_random()
			
		death_ui.visible = true
		
	await get_tree().create_timer(3.0).timeout

	# Reload scene
	get_tree().reload_current_scene()
