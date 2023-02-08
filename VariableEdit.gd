tool
extends Control

onready var box := $ScrollContainer/VBoxContainer
onready var add_line := $LineEdit
var timeline: Timeline setget _set_timeline; func _set_timeline(new: Timeline) -> void:
	if timeline == new:
		return
	clear()
	timeline = new
	if timeline:
		add_line.editable = true
		load_variables(timeline.variables)
	else:
		add_line.editable = false



func clear() -> void:
	for i in box.get_children():
		i.queue_free()


func load_variables(variables: Dictionary) -> void:
	for i in variables:
		add(i, str(variables[i]))


func add(var_name: String, value:= "") -> VarEdit:
	var new_var := VarEdit.new()
	new_var.set_var(var_name, value)
	box.add_child(new_var)
	new_var.connect("on_delete", self, "_on_var_delete", [var_name])
	new_var.connect("changed", self, "_on_var_changed", [var_name, new_var])
	return new_var


func _on_var_delete(name: String) -> void:
	if timeline:
		timeline.variables.erase(name)


func _on_var_changed(var_name: String, control: VarEdit) -> void:
	var new_name = control.get_var_name()
	if new_name != var_name:
		_on_var_delete(var_name)
		control.disconnect("changed", self, "_on_var_changed")
		control.connect("changed", self, "_on_var_changed", [new_name, control])
	timeline.variables[new_name] = control.get_var()
	print("mej")


func _on_LineEdit_text_changed(new_text: String) -> void:
	if timeline:
		var new = add(new_text, "")
		new.grab_focus_at_end()
		add_line.text = ""
	else:
		print("no Timeline selected")
