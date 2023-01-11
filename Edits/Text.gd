tool
extends EventEdit

onready var text := $TextEdit
var changed := false

func _ready() -> void:
	if event.lines:
		text.text = _extract_text(get_line())


func _extract_text(line: String) -> String:
	line = line.lstrip("text(\"").rstrip("\")")
	return line


func _on_TextEdit_text_changed() -> void:
	changed = true


func _on_TextEdit_focus_exited() -> void:
	if changed:
		var line = "text(\"%s\")" % text.text
		set_line(line)
		changed = false

