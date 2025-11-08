extends Area2D

@export var sign_texts: Dictionary[String, String] = {
	"JumpSign": "Press Space to jump",
	"WalkSign": "Use A/D or ←/→ to move",
	"OrbSign": "Collect the orbs"
}

var orb_count: int = 0

func _ready() -> void:
	monitoring = true
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _on_area_entered(a: Area2D) -> void:
	_process_hit(a)

func _on_body_entered(b: Node) -> void:
	_process_hit(b)

func _process_hit(n: Node) -> void:
	var target: Node = _find_with_group(n, "orb")
	if target:
		orb_count += 1
		target.queue_free()
		print("Orbs: %d" % orb_count)
		return

	target = _find_with_group(n, "sign")
	if target:
		var key: String = target.name
		var msg: String = sign_texts.get(key, key)
		print(msg)

func _find_with_group(start: Node, group_name: String) -> Node:
	var p: Node = start
	while p:
		if p.is_in_group(group_name):
			return p
		p = p.get_parent()
	return null
