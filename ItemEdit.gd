extends Control

signal request_close
signal request_move_up
signal request_move_down
signal request_save

var changed := false
onready var line := $LineEdit


func set_text(text) -> void:
	line.text = text


func _on_Up_pressed() -> void:
	emit_signal("request_move_up")


func _on_Down_pressed() -> void:
	emit_signal("request_move_down")


func _on_Close_pressed() -> void:
	emit_signal("request_close")


func _on_LineEdit_text_changed(new_text: String) -> void:
	changed = true


func _on_LineEdit_focus_exited() -> void:
	if changed:
		emit_signal("request_save", line.text)
