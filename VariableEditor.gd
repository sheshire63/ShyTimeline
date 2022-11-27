tool
extends VBoxContainer

class Entry:
	extends HBoxContainer

	signal name_changed(name)
	signal value_changed(name, value)
	signal deleted

	const types := [
		"Boolean",
		"Integer",
		"Float",
		"String",
	]

	var line := LineEdit.new()
	var type := OptionButton.new()
	var inputs := [
		CheckButton.new(),
		SpinBox.new(),
		SpinBox.new(),
		LineEdit.new(),
	]
	var close_button = Button.new()


	func _init(name := "", value = "") -> void:
		add_child(line)
		line.connect("text_changed", self, "on_var_name_changed")
		add_child(type)
		type.connect("item_selected", self, "on_type_selected")
		for i in types:
			type.add_item(i)
		for i in inputs:
			add_child(i)
			i.visible = false
		inputs[0].connect("toggled", self, "on_value_changed")
		inputs[1].rounded = true
		inputs[1].connect("value_changed", self, "on_value_changed")
		inputs[2].connect("value_changed", self, "on_value_changed")
		inputs[3].connect("text_changed", self, "on_value_changed")
		var value_type = typeof(value) - 1
		value_type = clamp(value_type, 0, 3)
		type.selected = value_type
		inputs[value_type].visible = true
		close_button.connect("pressed", self, "on_close")
		add_child(close_button)


	func on_var_name_changed(new) -> void:
		emit_signal("name_changed", new)


	func on_type_selected(index) -> void:
		for i in inputs.size():
			inputs[i].visible = index == i
		match index:
			0:
				emit_signal("value_changed", line.text, inputs[index].pressed)
			1:
				emit_signal("value_changed", line.text, int(inputs[index].value))
			2:
				emit_signal("value_changed", line.text, inputs[index].value)
			3:
				emit_signal("value_changed", line.text, inputs[0].text)


	func on_value_changed(new) -> void:
		emit_signal("value_changed", line.text, new)


	func get_value():
		match type.selected:
			0:
				return inputs[0].pressed
			1:
				return int(inputs[1].value)
			2:
				return inputs[2].value
			3:
				return inputs[3].text


	func on_close() -> void:
		get_parent().remove_child(self)
		emit_signal("deleted")
		self.queue_free()



	func get_name() -> String:
		return line.text


signal variables_changed
signal request_save

var timeline := ShyTimeline.new() setget _set_timeline;func _set_timeline(new):
	timeline = new
	setup()


func _ready() -> void:
	var add_button = Button.new()
	add_button.text = "+"
	add_button.connect("pressed", self, "add")
	add_child(add_button)


func add(name:= "", value = "") -> void:
	var entry = Entry.new("", value)
	add_child(entry)
	entry.connect("name_changed", self, "on_variable_changed")
	entry.connect("value_changed", self, "on_var_value_changed")
	emit_signal("variables_changed")
	emit_signal("request_save")


func setup() -> void:
	for i in get_children():
		if i is Entry:
			remove_child(i)
			i.queue_free()
	for i in timeline.variables:
		add(i, timeline.variables[i])


func save_data() -> Dictionary:
	var data = {}
	for i in get_children():
		if i is Entry:
			data[i.get_name()] = i.get_value()
	return data


func on_variable_changed(_name) -> void:
	emit_signal("variables_changed")
	emit_signal("request_save")


func on_var_value_changed(_name, value) -> void:
	emit_signal("request_save")