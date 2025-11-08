extends Node

@export var speed: float = 160.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0
@export var jump_cutoff_gravity_mult: float = 3.0

@onready var body: CharacterBody2D = get_parent() as CharacterBody2D
@onready var sprite: AnimatedSprite2D = body.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

enum State { IDLE, RUN, JUMP, FALL }
var state: State = State.IDLE

func _physics_process(delta: float) -> void:
	if body == null:
		return

	if not body.is_on_floor():
		body.velocity.y += gravity * delta
	if body.velocity.y < 0.0 and not Input.is_action_pressed("player_jump"):
		body.velocity.y += gravity * (jump_cutoff_gravity_mult - 1.0) * delta

	if Input.is_action_just_pressed("player_jump") and body.is_on_floor():
		body.velocity.y = jump_velocity

	var dir: float = Input.get_axis("player_left", "player_right")
	if dir != 0.0:
		body.velocity.x = dir * speed
	else:
		body.velocity.x = move_toward(body.velocity.x, 0.0, speed)

	body.move_and_slide()
	_update_state()
	_apply_animation()

func _update_state() -> void:
	if not body.is_on_floor():
		state = State.FALL if body.velocity.y > 0.0 else State.JUMP
	else:
		state = State.RUN if abs(body.velocity.x) > 5.0 else State.IDLE

func _apply_animation() -> void:
	if sprite == null:
		return

	if body.velocity.x < -1.0:
		sprite.flip_h = true
	elif body.velocity.x > 1.0:
		sprite.flip_h = false

	match state:
		State.IDLE:
			_play("idle")
		State.RUN:
			_play("right")
		State.JUMP:
			_play("jump")
		State.FALL:
			_play("fall")

func _play(animation_name: String) -> void:
	if sprite.animation != animation_name or not sprite.is_playing():
		sprite.play(animation_name)
