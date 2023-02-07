tool
extends Control

signal request_delete
signal request_move_up
signal request_move_down
signal text_changed

var changed := false
onready var line := $LineEdit


func _ready() -> void:
	line.grab_focus()


func set_text(text) -> void:
	line.text = text
	var l = line.get_line_count() -1
	line.cursor_set_line(l)
	line.cursor_set_column(line.get_line(l).length())


func get_text() -> String:
	return line.text


func _on_Up_pressed() -> void:
	emit_signal("request_move_up")


func _on_Down_pressed() -> void:
	emit_signal("request_move_down")


func _on_Close_pressed() -> void:
	emit_signal("request_delete")


func _on_LineEdit_text_changed() -> void:
	rect_size.y = 32.0 + line.get_line_height() * line.get_line_count()
	emit_signal("text_changed", line.text)

