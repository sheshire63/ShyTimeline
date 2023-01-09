tool
extends EventEdit

onready var text := $TextEdit
var changed = false

func _ready() -> void:
	text.text = event.lines[get_position_in_parent() - 1]


func _on_TextEdit_text_changed() -> void:
	changed = true


func _on_TextEdit_focus_exited() -> void:
	if changed:
		event.set_line(text.text, get_position_in_parent())
		changed = false
	
