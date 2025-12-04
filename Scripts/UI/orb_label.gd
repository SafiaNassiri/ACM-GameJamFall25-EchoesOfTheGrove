extends Node

var orb_count: int = 0
@export var orb_max: int = 13
@onready var orb_label: Label = %OrbLabel


func _ready() -> void:
    update_counter()
    
func update_counter() -> void:
    orb_label.text = "Orbs: " + str(orb_count) + "/" + str(orb_max)
    
func add_orb() -> void:
    orb_count += 1
    update_counter()
