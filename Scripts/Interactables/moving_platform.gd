extends Node2D

@export var move_offset: Vector2 = Vector2(0, -64)
@export var speed: float = 40.0
@export var wait_time: float = 1.0
@export var platform_area_path: NodePath  # Area2D for detecting player

var start_pos: Vector2
var target_pos: Vector2
var prev_pos: Vector2
var platform_area: Area2D
var players_on_platform: Array[CharacterBody2D] = []

func _ready() -> void:
	start_pos = global_position
	target_pos = start_pos + move_offset
	prev_pos = global_position

	if platform_area_path != NodePath(""):
		platform_area = get_node_or_null(platform_area_path) as Area2D
		if platform_area:
			platform_area.body_entered.connect(_on_body_entered)
			platform_area.body_exited.connect(_on_body_exited)
		else:
			push_error("Platform Area2D not found! Check platform_area_path.")

	# Start the movement as a coroutine
	_move_loop_async()

# async wrapper to start move_loop
func _move_loop_async() -> void:
	move_loop()

func move_loop() -> void:
	while true:
		while global_position.distance_to(target_pos) > 1.0:
			var delta_pos: Vector2 = (target_pos - global_position).normalized() * speed * get_physics_process_delta_time()
			global_position += delta_pos

			# Move players on platform
			for player in players_on_platform:
				if player:
					player.global_position += delta_pos
			
			if is_instance_valid(get_tree()):
				await get_tree().physics_frame
			else:
				return

		global_position = target_pos
		await get_tree().create_timer(wait_time).timeout

		var temp: Vector2 = start_pos
		start_pos = target_pos
		target_pos = temp

func _physics_process(delta: float) -> void:
	prev_pos = global_position

# Signal: player entered Area2D
func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		players_on_platform.append(body)

# Signal: player exited Area2D
func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D and body in players_on_platform:
		players_on_platform.erase(body)
