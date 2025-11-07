extends CharacterBody2D

@export var speed: float = 160.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0
@export var jump_cutoff_gravity_mult: float = 3.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

enum State { IDLE, RUN, JUMP, FALL }
var state: State = State.IDLE

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += gravity * delta
    if velocity.y < 0.0 and not Input.is_action_pressed("ui_accept"):
        velocity.y += gravity * (jump_cutoff_gravity_mult - 1.0) * delta

    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = jump_velocity

    var dir: float = Input.get_axis("ui_left", "ui_right")
    if dir != 0.0:
        velocity.x = dir * speed
    else:
        velocity.x = move_toward(velocity.x, 0.0, speed)

    move_and_slide()
    _update_state()
    _apply_animation()

func _update_state() -> void:
    if not is_on_floor():
        state = State.FALL if velocity.y > 0.0 else State.JUMP
    else:
        state = State.RUN if abs(velocity.x) > 5.0 else State.IDLE

func _apply_animation() -> void:
    if velocity.x < -1.0:
        sprite.flip_h = true
    elif velocity.x > 1.0:
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
