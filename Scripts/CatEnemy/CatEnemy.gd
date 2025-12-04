extends CharacterBody2D

@export var walk_speed: float = 30.0
@export var gravity: float = 900.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_check: RayCast2D = $PatrolChecks/WallCheck
@onready var patrol_checks: Node2D = $PatrolChecks
@onready var attack_hitbox: Area2D = $AttackHitbox

var direction: float = 1.0

func _ready() -> void:
	print("Cat Enemy Active")
	wall_check.enabled = true
	wall_check.collision_mask = 1 << 0  # adjust as needed

	# Connect attack hitbox signal
	if attack_hitbox:
		attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	velocity.x = walk_speed * direction

	wall_check.force_raycast_update()

	if wall_check.is_colliding():
		_flip_direction()

	move_and_slide()

	sprite.play("Run")

func _flip_direction() -> void:
	direction = -direction
	sprite.flip_h = direction < 0
	patrol_checks.scale.x = direction

# Called when cat's attack hitbox collides with any body
func _on_attack_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		# Try to call die() directly on the player
		if body.has_method("die"):
			body.die()
		else:
			# If the die() method is on a child DeathHandler
			var dh: DeathHandler = body.get_node_or_null("DeathHandler")
			if dh:
				dh.die()
