extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox

# NOTE: Must drag-and-drop the following nodes in the inspector to assign.
@export var timer_label: Label

# Change the per-scene defaults in the inspector
@export var walk_speed: float = 30.0
@export var gravity: float = 980.0
@export var chase_range: float = 300.0  # How far the cat can detect the player

var direction: int = 1  # 1 = right, -1 = left
var player: CharacterBody2D = null

func _ready() -> void:
	if attack_hitbox:
		attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)
	
	# Find the player node (assuming it's in the "Player" group)
	_find_player()

func _find_player() -> void:
	var players: Array = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0
	
	# Chase player if found and in range
	if player:
		var distance_to_player: float = global_position.distance_to(player.global_position)
		
		if distance_to_player < chase_range:
			# Calculate direction to player
			var direction_to_player: float = sign(player.global_position.x - global_position.x)
			
			if direction_to_player != 0:
				direction = direction_to_player
				velocity.x = walk_speed * direction
				
				# Flip sprite based on direction
				sprite.flip_h = direction < 0
		else:
			# Player too far, stop moving
			velocity.x = 0
	else:
		# No player found, patrol behavior
		velocity.x = walk_speed * direction
		if is_on_wall():
			_flip_direction()
	
	move_and_slide()
	
	# Play animation
	if abs(velocity.x) > 0:
		sprite.play("Run")
	else:
		sprite.play("Idle")  # Make sure you have an Idle animation, or use "Run"

func _flip_direction() -> void:
	direction = -direction
	sprite.flip_h = direction < 0

func _on_attack_hitbox_body_entered(body: Node) -> void:
	var dh: DeathHandler = body.get_node_or_null("DeathHandler")
	if body.is_in_group("Player") and dh and dh.has_method("die"):
		timer_label.add_time_on_respawn()  # NOTE: Remove this if you don't want cat's to add more time to the timer.
		dh.die()
