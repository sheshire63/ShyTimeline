tool
extends HBoxContainer
class_name VarEdit

signal changed
signal on_delete

var name_line := LineEdit.new()
var type := OptionButton.new()
var default_line := LineEdit.new()
var default_int := SpinBox.new()
var default_float := SpinBox.new()
var default_bool := CheckButton.new()
var close := Button.new()


func _ready() -> void:
	name_line.size_flags_horizontal = SIZE_EXPAND_FILL
	name_line.connect("text_changed", self, "_on_changed")
	add_child(name_line)

	type.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(type)
	type.add_item("String", TYPE_STRING)
	type.add_item("Integer", TYPE_INT)
	type.add_item("Float", TYPE_REAL)
	type.add_item("Boolean", TYPE_BOOL)
	type.connect("item_selected", self, "_on_changed")
	type.select(0)

	default_bool.size_flags_horizontal = SIZE_EXPAND_FILL
	default_bool.connect("toggled", self, "_on_changed")
	default_bool.visible = false
	add_child(default_bool)

	default_int.size_flags_horizontal = SIZE_EXPAND_FILL
	default_int.connect("value_changed", self, "_on_changed")
	default_int.visible = false
	add_child(default_int)

	default_float.size_flags_horizontal = SIZE_EXPAND_FILL
	default_float.connect("value_changed", self, "_on_changed")
	default_float.visible = false
	add_child(default_float)

	default_line.size_flags_horizontal = SIZE_EXPAND_FILL
	default_line.connect("text_changed", self, "_on_changed")
	add_child(default_line)

	close.text = "X"
	close.connect("pressed", self, "_on_close")
	add_child(close)


func set_var(var_name: String, default_value) -> void:
	name_line.text = var_name
	var t = typeof(default_value)
	type.select(type.get_item_index(t))
	default_line.visible = false
	default_float.visible = false
	default_int.visible = false
	default_bool.visible = false
	match t:
		TYPE_STRING:
			default_line.text = default_value
			default_line.visible = true
		TYPE_INT:
			default_int.value = default_value
			default_int.visible = true
		TYPE_REAL:
			default_float.value = default_value
			default_float.visible = true
		TYPE_BOOL:
			default_bool.pressed = default_value
			default_bool.visible = true


func get_var():
	match type.get_selected_id():
		TYPE_STRING:
			return default_line.text
		TYPE_INT:
			return int(default_int.value)
		TYPE_REAL:
			return default_float.value
		TYPE_BOOL:
			return default_bool.pressed


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
