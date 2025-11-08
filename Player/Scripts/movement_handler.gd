extends Node

@export var speed: float = 90.0
@export var jump_velocity: float = -350.0
@export var gravity: float = 980.0
@export var jump_cutoff_gravity_mult: float = 3.0

@export var dash_multiplier: float = 2.0
@export var dash_duration: float = 0.18
@export var dash_cooldown: float = 0.5

@onready var body: CharacterBody2D = get_parent() as CharacterBody2D
@onready var sprite: AnimatedSprite2D = body.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

enum State { IDLE, RUN, JUMP, FALL, DASH }
var state: State = State.IDLE

var _dash_time: float = 0.0
var _dash_cd: float = 0.0
var _dash_dir: int = 0
var _dash_speed: float = 0.0

func _physics_process(delta: float) -> void:
	if body == null:
		return

	if _dash_cd > 0.0:
		_dash_cd -= delta

	if _dash_time > 0.0:
		_dash_time -= delta
		body.velocity.x = _dash_dir * _dash_speed
		body.move_and_slide()
		_update_state(true)
		_apply_animation()
		return

	if not body.is_on_floor():
		body.velocity.y += gravity * delta
	if body.velocity.y < 0.0 and not Input.is_action_pressed("player_jump"):
		body.velocity.y += gravity * (jump_cutoff_gravity_mult - 1.0) * delta

	if Input.is_action_just_pressed("player_jump") and body.is_on_floor():
		body.velocity.y = jump_velocity

	var dir: float = Input.get_axis("player_left", "player_right")
	if Input.is_action_just_pressed("player_dash"):
		_try_start_dash(dir)

	if dir != 0.0:
		body.velocity.x = dir * speed
	else:
		body.velocity.x = move_toward(body.velocity.x, 0.0, speed)

	body.move_and_slide()
	_update_state(false)
	_apply_animation()

func _try_start_dash(input_dir: float) -> void:
	if _dash_cd > 0.0:
		return
	var dir_sign: int = 0
	if input_dir != 0.0:
		dir_sign = 1 if input_dir > 0.0 else -1
	elif abs(body.velocity.x) > 1.0:
		dir_sign = 1 if body.velocity.x > 0.0 else -1
	else:
		return
	_dash_dir = dir_sign
	_dash_speed = max(abs(body.velocity.x), speed) * dash_multiplier
	_dash_time = dash_duration
	_dash_cd = dash_cooldown
	state = State.DASH
	if sprite:
		if _dash_dir < 0: sprite.flip_h = true
		elif _dash_dir > 0: sprite.flip_h = false
		_play("dash")

func _update_state(is_dashing: bool) -> void:
	if is_dashing:
		state = State.DASH
		return
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
		State.IDLE: _play("idle")
		State.RUN: _play("right")
		State.JUMP: _play("jump")
		State.FALL: _play("fall")
		State.DASH: _play("dash")

func _play(name: String) -> void:
	if sprite.animation != name or not sprite.is_playing():
		sprite.play(name)
