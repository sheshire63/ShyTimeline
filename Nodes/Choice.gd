tool
extends "res://addons/ShyTimeline/Nodes/Text.gd"


class ChoiceData:
	extends NodeData

	export var test := ""

	func load_data(data := {}) -> void:
		.load_data(data)


	func save_data() -> Dictionary:
		var data = .save_data()
		return data



onready var c_choices := $ScrollContainer/VBoxContainer


func _init():
	data = ChoiceData.new()


func _ready() -> void:
	if !c_choices.get_child_count():
		add_choice()


func get_event() -> Dictionary:
	var event := .get_event()
	var choices = []
	for i in c_choices.get_children():
		choices.append(lex(i.text))
	event.choices = choices
	return event


func _clear() -> void:
	for i in c_choices.get_children():
		c_choices.remove_child(i)
		i.queue_free()


func _save_data() -> Dictionary:
	var data := ._save_data()
	var choices := []
	for i in c_choices.get_children():
		choices.append(i.text)
	data.choices = choices
	return data


func _load_data(data:= {}) -> void:
	_clear()
	for i in data.choices:
		add_choice(i)
	._load_data(data)


func _delete() -> void:
	pass


func _copy(copy) -> void:#if you need to set somthing in the copy.
	pass


func add_choice(choice := "") -> void:
	"""
	# we want the choice to be a dragable object.
	#	so make it a custom control?
	#	we can change it later
	# keep the data in choice a string
	#	add connect data in save
	"""
	var line = LineEdit.new()
	line.size_flags_horizontal = SIZE_EXPAND_FILL
	line.text = choice
	line.connect("text_changed", self, "_on_line_changed", [])
	line.connect("text_entered", self, "_on_line_entered")
	c_choices.add_child(line)
	line.grab_focus()


func _on_line_changed(new) -> void:
	pass


func _on_Add_pressed() -> void:
	add_choice()


func _on_Remove_pressed() -> void:
	if c_choices.get_child_count():
		var child = c_choices.get_child(c_choices.get_child_count() - 1)
		c_choices.remove_child(child)
		child.queue_free()


func _on_line_entered(_new: String) -> void:
	add_choice()