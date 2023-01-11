tool
extends EventEdit

onready var box := $VBoxContainer
var time := SpinBox.new()


func _ready() -> void:
	var regex := RegEx.new()
	var regex2 := RegEx.new()
	var err = regex.compile("choice\\(\\[(?<choices>.*?)\\](?:\\s*,\\s*(?<time>(?:\\d*\\.)?\\d+))?\\)")
	var err2 = regex2.compile('"(?:[^\\\\]|\\.)*?"')
	assert(err == OK and err2 == OK)
	_add_time_control()
	if has_line():
		var res = regex.search(get_line())
		if res:
			var choices = regex2.search_all(res.get_string("choices"))
			for i in choices:
				add(i.strings[0].strip_edges().trim_prefix('"').trim_suffix('"'))
			if res.get_string("time"):
				time.value = float(res.get_string("time"))
			else:
				time.value = -1.0
		else:
			printerr("cant convert line")
	if box.get_child_count() == 0:
		add()
	_update_size()


# public ----------------------------------------------------------------

func add(choice:= "") -> void:
	var control = LineEdit.new()
	control.text = choice
	box.size_flags_horizontal = SIZE_EXPAND_FILL
	control.connect("text_changed", self, "_on_choice_changed", [control])
	box.add_child(control)


# private ----------------------------------------------------------------

func _on_choice_changed(text: String, control: LineEdit) -> void:
	if text != "":
		if control.get_position_in_parent() == box.get_child_count() - 1:
			add()
	else:
		box.remove_child(control)
		control.queue_free()
	_update_text()


func _update_text() -> void:
	var choices := []
	for i in box.get_child_count() - 1:
		choices.append(get_child(i).text)
	set_line("choice([\"%s\"], %f)" % ['", "'.join(choices), time.value])#todo we need quotes


func _add_time_control() -> void:
	time.prefix = "Time:"
	time.suffix = "s"
	time.connect("value_changed", self, "_on_time_changed")
	bottom_box.add_child(time)


func _on_time_changed(_value: float) -> void:
	_update_text()
