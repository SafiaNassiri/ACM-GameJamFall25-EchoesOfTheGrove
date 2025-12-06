extends CharacterBody2D

# == Enemy Stats ==
@export var walk_speed: float = 30.0
@export var run_speed: float = 70.0
@export var gravity: float = 900.0
@export var health: int = 3

# == State Machine ==
enum State { PATROL, CHASE, ATTACK, HURT }
var current_state: State = State.PATROL
var player_ref: Node2D = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var patrol_checks: Node2D = $PatrolChecks
@onready var ledge_check: RayCast2D = $PatrolChecks/LedgeCheck
@onready var wall_check: RayCast2D = $PatrolChecks/WallCheck
@onready var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D

var direction: int = 1:
	set(value):
		if value == 0:
			return
		direction = sign(value)
		animated_sprite.flip_h = direction < 0
		detection_area.scale.x = float(direction)
		attack_hitbox.scale.x = float(direction)
		patrol_checks.scale.x = float(direction)

func _ready() -> void:
	direction = 1
	ledge_check.enabled = true
	wall_check.enabled = true
	if attack_shape:
		attack_shape.disabled = true
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	match current_state:
		State.PATROL:
			_patrol_state(delta)
		State.CHASE:
			_chase_state(delta)
		State.ATTACK:
			_attack_state(delta)
		State.HURT:
			_hurt_state(delta)

	move_and_slide()

# == State Functions ==

func _patrol_state(_delta: float) -> void:
	animated_sprite.play("Run")
	velocity.x = walk_speed * float(direction)

	var should_turn: bool = false
	if not ledge_check.is_colliding():
		should_turn = true
	if wall_check.is_colliding():
		should_turn = true
	if is_on_wall():
		should_turn = true

	if should_turn:
		direction = -direction

func _chase_state(_delta: float) -> void:
	animated_sprite.play("Run")
	if player_ref == null:
		current_state = State.PATROL
		return

	var dx: float = player_ref.global_position.x - global_position.x
	var player_dir: int = sign(dx)
	if player_dir != 0:
		direction = player_dir

	velocity.x = run_speed * float(direction)

	if global_position.distance_to(player_ref.global_position) < 40.0:
		current_state = State.ATTACK

func _attack_state(_delta: float) -> void:
	animated_sprite.play("Attack")
	velocity.x = 0.0
	if attack_shape:
		attack_shape.disabled = false

func _hurt_state(_delta: float) -> void:
	animated_sprite.play("Hurt")
	velocity.x = 0.0

# == Public Functions ==

func take_damage(amount: int) -> void:
	if current_state == State.HURT:
		return
	health -= amount
	current_state = State.HURT
	if health <= 0:
		queue_free()

# == Animation Finished ==

func _on_animation_finished() -> void:
	if animated_sprite.animation == "Attack":
		if attack_shape:
			attack_shape.disabled = true
		if player_ref != null:
			current_state = State.CHASE
		else:
			current_state = State.PATROL
	elif animated_sprite.animation == "Hurt":
		if health > 0:
			if player_ref != null:
				current_state = State.CHASE
			else:
				current_state = State.PATROL

# == Detection / Hurtbox Signals ==

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_ref = body
		if current_state == State.PATROL:
			current_state = State.CHASE

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null
		if current_state == State.CHASE:
			current_state = State.PATROL

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		take_damage(1)
