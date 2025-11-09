extends Node

@export var start_time: float = 90.0
@onready var timer_label: Label = %TimerLabel

var time_left: float
var finished: bool = false
var death_handler: Node = null

func _ready() -> void:
	reset_timer()
	_resolve_death_handler()

func _process(delta: float) -> void:
	if finished:
		return

	if time_left > 0.0:
		time_left -= delta
		timer_label.text = str(int(ceil(time_left)))
	else:
		_on_timer_finished()

func _on_timer_finished() -> void:
	finished = true
	timer_label.text = "0"
	if death_handler and death_handler.has_method("die"):
		death_handler.call("die")
	else:
		print("Time's up — DeathHandler not found.")

func reset_timer() -> void:
	time_left = start_time
	finished = false
	timer_label.text = str(int(ceil(time_left)))

# ---- Find DeathHandler node ----
func _resolve_death_handler() -> void:
	# Wait one frame so instanced scenes finish entering the tree
	await get_tree().process_frame

	var scene: Node = get_tree().current_scene
	if scene:
		# 1) Try Player/DeathHandler path if that structure exists
		var player: Node = scene.find_child("Player", true, false)
		if player:
			var dh: Node = player.get_node_or_null("DeathHandler")
			if dh:
				death_handler = dh
				return

		# 2) Fallback: find any node named "DeathHandler" anywhere
		var any_dh: Node = scene.find_child("DeathHandler", true, false)
		if any_dh:
			death_handler = any_dh
			return

	# 3) If still not found, listen for nodes being added
	if not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)

func _on_node_added(n: Node) -> void:
	# Grab first node named DeathHandler that shows up
	if n.name == "DeathHandler":
		death_handler = n
		if get_tree().node_added.is_connected(_on_node_added):
			get_tree().node_added.disconnect(_on_node_added)
