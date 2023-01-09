tool
extends EventEdit
class_name TextEventEdit

onready var text := $TextEdit
var changed := false

func _ready() -> void:
	if event.lines:
		text.text = _extract_text(event.lines[get_position_in_parent() - 1])


func _extract_text(line: String) -> String:
	line = line.lstrip("text(\"").rstrip("\")")
	return line


func _on_TextEdit_text_changed() -> void:
	changed = true


func _on_TextEdit_focus_exited() -> void:
	if changed:
		var line = "text(\"%s\")" % text.text
		event.set_line(line, get_position_in_parent())
		changed = false

