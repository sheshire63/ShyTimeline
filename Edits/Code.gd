tool
extends EventEdit

onready var text := $TextEdit
var changed = false

func _ready() -> void:
	text.text = get_line()


func _on_TextEdit_text_changed() -> void:
	changed = true
	_update_size()


func _on_TextEdit_focus_exited() -> void:
	if changed:
		set_line(text.text)
		changed = false


static func get_type() -> String:
	return "Code"


func _update_size() -> void:
	var size = text.margin_top - text.margin_bottom
	size += max(text.get_line_count() * text.get_line_height(), 64)
	rect_size.y = size
	rect_min_size.y = size
