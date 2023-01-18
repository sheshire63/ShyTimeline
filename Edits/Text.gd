tool
extends EventEdit

onready var text := $TextEdit
var changed := false

func _ready() -> void:
	if event.lines:
		text.text = re_match.get_string("text")


# static/override ----------------------------------------------------------------

static func get_regex() -> String:
	return 'text\\((?:["\'](?<text>(?:[^\'"]|\\\\\\.)*)["\'])?\\)'


static func get_type() -> String:
	return "Text"


# private ----------------------------------------------------------------

func _on_TextEdit_text_changed() -> void:
	changed = true
	_update_size()


func _on_TextEdit_focus_exited() -> void:
	if changed:
		var line = "text(\"%s\")" % text.text.c_escape()
		set_line(line)
		changed = false


func _update_size() -> void:
	var size = text.margin_top + abs(text.margin_bottom)
	size += max((text.get_line_count() + 1)  * text.get_line_height(), 64)
	rect_size.y = size
	rect_min_size.y = size
