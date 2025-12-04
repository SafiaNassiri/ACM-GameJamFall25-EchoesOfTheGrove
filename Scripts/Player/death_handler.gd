extends Node
class_name DeathHandler

var _is_dying: bool = false

@onready var body: CharacterBody2D = get_parent() as CharacterBody2D
@onready var sprite: AnimatedSprite2D = get_parent().get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
@onready var anim: AnimationPlayer = get_parent().get_node_or_null("AnimationPlayer") as AnimationPlayer
@onready var death_ui: Control = $"../../Ui/DeathUI"

func die() -> void:
    if _is_dying:
        return
    _is_dying = true

    # Stop all other scripts on the player so animations aren't overwritten
    for child in get_parent().get_children():
        if child != self and not (child == sprite or child == anim):
            child.set_process(false)
            child.set_physics_process(false)

    if body:
        body.collision_layer = 0
        body.collision_mask = 0
        if "velocity" in body:
            body.velocity = Vector2.ZERO

    if sprite:
        sprite.play("death")
        await sprite.animation_finished
    elif anim:
        anim.play("death")
        await anim.animation_finished
        
    var prev_death_visible: bool = death_ui.visible if death_ui != null else false
    if is_instance_valid(death_ui):
        death_ui.visible = true
    await get_tree().create_timer(5.0).timeout
    if is_instance_valid(death_ui):
        death_ui.visible = prev_death_visible

    # Reload scene
    get_tree().reload_current_scene()
