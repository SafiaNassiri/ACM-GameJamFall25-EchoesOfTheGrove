extends Area2D

@export var sign_texts: Dictionary[String, String] = {
	"JumpSign": "{jump} Press to jump",
	"WalkSign": "{move} Move left/right",
	"OrbSign": "Collect the orbs"
}

const TOKEN_REGEX: String = r"\{([a-zA-Z0-9_]+)\}"
var icon_token_re: RegEx = RegEx.new()
var orb_count: int = 0

var pixel_font: Font = preload("res://Fonts/PixelOperator.ttf")

var action_icons: Dictionary[String, Array] = {
	"move": [
		preload("res://Assets/ui_icon_pack/resources/keyboard/icon_A_key.tres"),
		preload("res://Assets/ui_icon_pack/resources/keyboard/icon_D_key.tres")
	],
	"jump": [
		preload("res://Assets/ui_icon_pack/resources/keyboard/icon_Space_key.tres"),
		preload("res://Assets/ui_icon_pack/resources/keyboard/icon_W_key.tres")
	]
}

@export var base_scale: float = 1.0
@export var icon_scale: float = 0.5
@export var icon_gap: float = 4.0
@export var chunk_gap: float = 6.0

@export var bg_color: Color = Color(0.85, 0.85, 0.85, 0.85)
@export var font_px: int = 16

@export var max_width: float = 180.0
@export var pad_x: float = 6.0
@export var pad_y: float = 4.0

func _ready() -> void:
	icon_token_re.compile(TOKEN_REGEX)
	monitoring = true
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	body_exited.connect(_on_body_exited)
	area_exited.connect(_on_area_exited)

func _on_area_entered(a: Area2D) -> void: _process_hit(a)
func _on_body_entered(b: Node) -> void: _process_hit(b)
func _on_area_exited(a: Area2D) -> void: _process_exit(a)
func _on_body_exited(b: Node) -> void: _process_exit(b)

func _process_hit(n: Node) -> void:
	var orb: Node = _find_with_group(n, "orb")
	if orb != null:
		orb_count += 1
		orb.queue_free()
		return

	var sign: Node2D = _find_with_group(n, "sign") as Node2D
	if sign == null:
		return

	var prompt: Node2D = sign.get_node_or_null("Prompt") as Node2D
	if prompt == null:
		prompt = Node2D.new()
		prompt.name = "Prompt"
		sign.add_child(prompt)

	var text: String = sign_texts.get(sign.name, sign.name)
	_render_prompt(prompt, text)
	_center_prompt(prompt)
	prompt.scale = Vector2.ONE * base_scale
	prompt.visible = true

func _process_exit(n: Node) -> void:
	var sign: Node2D = _find_with_group(n, "sign") as Node2D
	if sign == null:
		return
	var prompt: Node2D = sign.get_node_or_null("Prompt") as Node2D
	if prompt != null:
		prompt.visible = false
		_clear(prompt)

func _render_prompt(prompt: Node2D, text: String) -> void:
	_clear(prompt)

	var bg: ColorRect = ColorRect.new()
	bg.color = bg_color
	prompt.add_child(bg)

	var x: float = 0.0
	var y: float = 0.0
	var line_h: float = _line_height()
	var last_end: int = 0
	var max_line_w: float = 0.0
	var matches: Array = icon_token_re.search_all(text)

	for i: int in matches.size():
		var m: RegExMatch = matches[i]
		var start: int = m.get_start()
		var end: int = m.get_end()
		var key: String = m.get_string(1)

		var pre: String = text.substr(last_end, start - last_end)
		if pre.length() > 0:
			var w_pre: float = _measure_text(pre)
			if x > 0.0 and x + w_pre > max_width:
				max_line_w = max(max_line_w, x)
				x = 0.0
				y += line_h
			var l_pre: Label = _make_label(pre)
			l_pre.position = Vector2(x, y)
			prompt.add_child(l_pre)
			x += w_pre

		var icons: Array = action_icons.get(key, []) as Array
		if icons.size() > 0:
			var w_icons: float = 0.0
			var h_icons: float = 0.0
			for j: int in icons.size():
				var t: Texture2D = icons[j] as Texture2D
				var s: Vector2 = Vector2(t.get_size()) * icon_scale
				w_icons += s.x
				if j < icons.size() - 1:
					w_icons += icon_gap
				h_icons = max(h_icons, s.y)

			var token_h: float = max(line_h, h_icons)
			if x > 0.0 and x + w_icons > max_width:
				max_line_w = max(max_line_w, x)
				x = 0.0
				y += token_h

			var v_offset: float = (token_h - h_icons) * 0.5
			for j2: int in icons.size():
				var tex: Texture2D = icons[j2] as Texture2D
				var sz2: Vector2 = Vector2(tex.get_size()) * icon_scale
				var tr: TextureRect = TextureRect.new()
				tr.texture = tex
				tr.scale = Vector2.ONE * icon_scale
				tr.position = Vector2(x, y + v_offset)
				prompt.add_child(tr)
				x += sz2.x
				if j2 < icons.size() - 1:
					x += icon_gap

			line_h = max(line_h, token_h)
			x += chunk_gap

		last_end = end

	var tail: String = text.substr(last_end)
	if tail.length() > 0:
		var w_tail: float = _measure_text(tail)
		if x > 0.0 and x + w_tail > max_width:
			max_line_w = max(max_line_w, x)
			x = 0.0
			y += line_h
		var l_tail: Label = _make_label(tail)
		l_tail.position = Vector2(x, y)
		prompt.add_child(l_tail)
		x += w_tail

	max_line_w = max(max_line_w, x)
	var total_w: float = max_line_w + pad_x * 2.0
	var total_h: float = y + line_h + pad_y * 2.0

	bg.position = Vector2(-pad_x, -pad_y)
	bg.size = Vector2(total_w, total_h)

func _make_label(text: String) -> Label:
	var l: Label = Label.new()
	l.text = text
	l.add_theme_font_override("font", pixel_font)
	l.add_theme_font_size_override("font_size", font_px)
	l.add_theme_color_override("font_color", Color(0.12, 0.12, 0.12))
	return l

func _measure_text(text: String) -> float:
	return pixel_font.get_string_size(text, font_px).x

func _line_height() -> float:
	return max(float(font_px), _icon_max_height())

func _icon_max_height() -> float:
	var h: float = 0.0
	for k: String in action_icons.keys():
		var arr: Array = action_icons[k] as Array
		for i: int in arr.size():
			var t: Texture2D = arr[i] as Texture2D
			h = max(h, float(t.get_size().y) * icon_scale)
	return h

func _clear(prompt: Node2D) -> void:
	for c: Node in prompt.get_children():
		c.queue_free()

func _center_prompt(prompt: Node2D) -> void:
	var r: Rect2 = _content_rect(prompt)
	var shift_x: float = -(r.size.x * 0.5)
	for c: Node in prompt.get_children():
		if c is Node2D:
			(c as Node2D).position.x += shift_x
		elif c is Control:
			(c as Control).position.x += shift_x

func _content_rect(prompt: Node2D) -> Rect2:
	var a: Rect2 = Rect2()
	var first: bool = true
	for c: Node in prompt.get_children():
		if c is Control:
			var ctrl: Control = c as Control
			var r: Rect2 = Rect2(ctrl.position, ctrl.size)
			a = r if first else a.merge(r)
			first = false
	return a

func _find_with_group(start: Node, group_name: String) -> Node:
	var p: Node = start
	while p != null:
		if p.is_in_group(group_name):
			return p
		p = p.get_parent()
	return null
