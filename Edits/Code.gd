tool
extends EventEdit

onready var text := $TextEdit
var changed = false

func _ready() -> void:
	text.text = get_line()


func _on_TextEdit_text_changed() -> void:
	changed = true


func _on_TextEdit_focus_exited() -> void:
	if changed:
		set_line(text.text)
		changed = false

