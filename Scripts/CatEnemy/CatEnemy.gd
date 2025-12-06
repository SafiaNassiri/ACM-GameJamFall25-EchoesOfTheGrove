extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox

# NOTE: Must drag-and-drop the following nodes in the inspector to assign.
@export var timer_label: Label

# Change the per-sceen defaults in the inspector
@export var walk_speed: float = 30.0
@export var gravity: float = 980.0

var direction: int = 1  # 1 = right, -1 = left

func _ready() -> void:
	if attack_hitbox:
		attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	velocity.x = walk_speed * direction

	move_and_slide()

	if is_on_wall():
		_flip_direction()

	sprite.play("Run")

func _flip_direction() -> void:
	direction = -direction
	sprite.flip_h = direction < 0

func _on_attack_hitbox_body_entered(body: Node) -> void:
	var dh : DeathHandler = body.get_node_or_null("DeathHandler")
	if body.is_in_group("Player") and dh and dh.has_method("die"):
		timer_label.add_time_on_respawn()	# NOTE: Remove this if you don't want cat's to add more time to the timer.
		dh.die()
