extends Control
class_name VarEdit

signal changed
signal on_delete

var name_line := LineEdit.new()
var type := OptionButton.new()
var default := LineEdit.new()
var close := Button.new()


func _ready() -> void:
	name_line.anchor_bottom = 1.0
	name_line.anchor_right = 0.4
	name_line.connect("text_changed", self, "_on_changed")
	add_child(name_line)
	
	type.anchor_bottom = 1.0
	type.anchor_left = 0.4
	type.anchor_right = 0.6
	add_child(type)
	type.add_item("String", TYPE_STRING)
	type.add_item("Integer", TYPE_INT)
	type.add_item("Float", TYPE_REAL)
	type.add_item("Boolean", TYPE_BOOL)
	type.connect("item_selected", self, "_on_changed")
	
	default.anchor_bottom = 1.0
	default.anchor_left = 0.6
	default.anchor_right = 1.0
	default.margin_right = -32.0
	default.connect("text_changed", self, "_on_changed")
	add_child(default)

	close.text = "X"
	close.anchor_left = 1.0
	close.margin_left = -32.0
	close.margin_bottom = 32.0
	close.connect("pressed", self, "_on_close")
	add_child(close)


func set_var(var_name: String, default_value) -> void:
	name_line.text = var_name
	type.select(type.get_item_index(typeof(default_value)))
	default.text = str(default_value)


func get_var():
	return convert(default.text, type.get_selected_id())


func get_var_name() -> String:
	return name_line.text


func grab_focus_at_end() -> void:
	name_line.grab_focus()
	name_line.caret_position = name_line.text.length()


func _on_close() -> void:
	emit_signal("on_delete")
	queue_free()


func _on_changed(_x) -> void:
	emit_signal("changed")
