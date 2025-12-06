extends Node2D

@onready var platform_area: Area2D = $PlatformArea
@onready var start_point_node: Node2D = $StartPos
@onready var end_point_node: Node2D = $EndPos

@export var speed: float = 40.0

var start_pos: Vector2
var end_pos: Vector2
var current_target: Vector2
var going_to_end: bool = true

var players_on_platform: Array[CharacterBody2D] = []

func _ready() -> void:
	# Capture their initial world positions ONCE
	start_pos = start_point_node.global_position
	end_pos = end_point_node.global_position

	# Optionally move platform to start
	global_position = start_pos
	current_target = end_pos

	platform_area.body_entered.connect(_on_body_entered)
	platform_area.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	var to_target: Vector2 = current_target - global_position

	if to_target.length() > 1.0:
		var move_vec: Vector2 = to_target.normalized() * speed * delta

		# Don’t overshoot target
		if move_vec.length() > to_target.length():
			move_vec = to_target

		# Move platform
		global_position += move_vec

		# Move any players riding it
		for player in players_on_platform:
			if player:
				player.global_position += move_vec
	else:
		# Snap exactly to target
		global_position = current_target

		# Flip direction
		going_to_end = not going_to_end
		current_target = end_pos if going_to_end else start_pos

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		players_on_platform.append(body)

func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D and body in players_on_platform:
		players_on_platform.erase(body)
