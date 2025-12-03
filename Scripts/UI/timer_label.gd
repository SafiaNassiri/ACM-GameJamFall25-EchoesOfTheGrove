extends Node

@export var start_time: float = 90.0          # initial time (set per level)
@export var time_bonus_on_death: float = 60.0 # how much time to add when you die

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
		add_time_on_respawn()
	else:
		print("Time's up — DeathHandler not found.")

func reset_timer() -> void:
	time_left = start_time
	finished = false
	timer_label.text = str(int(ceil(time_left)))

# -------------------------------------------------------
# NEW: Add bonus time each time the player respawns
# -------------------------------------------------------
func add_time_on_respawn() -> void:
	time_left = start_time + time_bonus_on_death
	start_time = time_left  # update baseline so each death keeps stacking
	finished = false
	timer_label.text = str(int(ceil(time_left)))
# -------------------------------------------------------

# ---- Find DeathHandler node ----
func _resolve_death_handler() -> void:
	await get_tree().process_frame

	var scene: Node = get_tree().current_scene
	if scene:
		var player: Node = scene.find_child("Player", true, false)
		if player:
			var dh: Node = player.get_node_or_null("DeathHandler")
			if dh:
				death_handler = dh
				return

		var any_dh: Node = scene.find_child("DeathHandler", true, false)
		if any_dh:
			death_handler = any_dh
			return

	if not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)

func _on_node_added(n: Node) -> void:
	if n.name == "DeathHandler":
		death_handler = n
		if get_tree().node_added.is_connected(_on_node_added):
			get_tree().node_added.disconnect(_on_node_added)
