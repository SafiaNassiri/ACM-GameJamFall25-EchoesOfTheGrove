extends CharacterBody2D

# ==Enemy Stats ===
@export var walk_speed: float = 30.0
@export var run_speed: float = 70.0
@export var gravity: float = 900.0
@export var health: int = 3

# === State Machine ===
enum State { PATROL, CHASE, ATTACK, HURT}
var current_state: State = State.PATROL
var player_ref: Node2D = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var ledge_check: RayCast2D = $PatrolChecks/LedgeCheck
@onready var wall_check: RayCast2D = $PatrolChecks/WallCheck

var direction: float = 1.0:
	set(value):
		direction = value
		if direction == 1.0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
		detection_area.scale.x = direction
		attack_hitbox.scale.x = direction
		ledge_check.position.x = abs(ledge_check.position.x) * direction
		wall_check.position.x = abs(wall_check.position.x) * direction

func _ready() -> void:
	self.direction = 1.0
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

# === State Functions ===
func _patrol_state(_delta:float) -> void:
	animated_sprite.play('Run')
	velocity.x = walk_speed * direction
	if not ledge_check.is_colliding() or wall_check.is_colliding():
		direction *= -1.0 # flip the direction

func _chase_state(_delta:float) -> void:
	animated_sprite.play("Run")
	if player_ref == null:
		current_state = State.PATROL
		return
	var player_direction: float = sign(player_ref.global_position.x - self.global_position.x)
	direction = player_direction
	velocity.x = run_speed * direction
	if global_position.distance_to(player_ref.global_position) < 40:
		current_state = State.ATTACK

func _attack_state(_delta:float) -> void:
	animated_sprite.play("Attack")
	velocity.x = 0 #Stop moving to attack
	var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D as CollisionShape2D
	if attack_shape:
		attack_shape.disabled = false

func _hurt_state(_delta:float) -> void:
	animated_sprite.play("Idle")
	velocity.x = 0

# == Public Functions ===
func take_damage(amount: int) -> void:
	if current_state == State.HURT:
		return
	health -= amount
	current_state = State.HURT
	if health <= 0:
		queue_free()

# === Signal Connection ===
func _on_animation_finished() -> void:
	var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D as CollisionShape2D
	if animated_sprite.animation == "attack":
		if attack_shape:
			attack_shape.disabled = true
		current_state = State.CHASE
	if current_state == State.HURT:
		current_state = State.CHASE

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_ref = body
		current_state = State.CHASE

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null
		current_state = State.PATROL

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		take_damage(1)
