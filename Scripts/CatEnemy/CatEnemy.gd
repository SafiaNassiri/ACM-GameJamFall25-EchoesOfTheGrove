extends CharacterBody2D

@export var walk_speed: float = 30.0
@export var gravity: float = 900.0
@export var health: int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
#@onready var ledge_check: RayCast2D = $PatrolChecks/LedgeCheck
@onready var wall_check: RayCast2D = $PatrolChecks/WallCheck
@onready var patrol_checks: Node2D = $PatrolChecks   # <-- FIXED HERE

var direction := 1.0

func _ready() -> void:
	print("THIS CAT IS ACTIVE")
	#ledge_check.enabled = true
	wall_check.enabled = true

	#ledge_check.collision_mask = 1 << 0
	wall_check.collision_mask = 1 << 0

func _physics_process(delta: float) -> void:
	print("Wall colliding:", wall_check.is_colliding())

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	velocity.x = walk_speed * direction

	#ledge_check.force_raycast_update()
	wall_check.force_raycast_update()

	#if not ledge_check.is_colliding():
		#_flip_direction()

	if wall_check.is_colliding():
		_flip_direction()

	move_and_slide()

	sprite.play("Run")

func _flip_direction() -> void:
	direction = -direction

	# flip sprite
	sprite.flip_h = (direction < 0)

	# flip raycasts node
	patrol_checks.scale.x = direction

	print("Flipped to", direction)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()

func _on_attack_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.die()
