tool
extends EventEdit

onready var box := $VBoxContainer
var time := SpinBox.new()

var text_changed = false

#TODO REMAKE THIS EDIT

"""
its currently broken
make the choices a custom scene/node
add a pseude input that creates a choice on text input
automaticly create the entry for timeout if time > 0
"""

func _ready() -> void:
	_add_time_control()
	var regex = RegEx.new()
	var err = regex.compile('[\'"](?<choice>(?:[^\\\\\'"]|(?:\\\\.))*)[\'"]')
	assert(err == OK)
	assert(re_match)
	var res = regex.search_all(re_match.get_string("choices"))
	for i in res:
		add(i.get_string("choice").c_unescape())
	add()


# public ----------------------------------------------------------------

func add(choice:= "") -> void:
	assert(is_inside_tree())
	var control = LineEdit.new()
	control.text = choice
	box.size_flags_horizontal = SIZE_EXPAND_FILL
	control.connect("focus_exited", self, "_on_choice_end_edit", [control])
	control.connect("text_changed", self, "_on_choice_changed")
	if box.get_child_count() == 0:
		event.add_next_entry("%dchoice-Timeout" % get_position_in_parent())
	else:
		event.add_next_entry("%dchoice%d" % [get_position_in_parent(), box.get_child_count() -1])
	box.add_child(control)
	control.grab_focus()
	_update_size()


# static/overrides ----------------------------------------------------------------

static func get_regex() -> String:
	return "choice\\(\\s*(?:\\[(?<choices>.*?)\\](?:\\s*,\\s*(?<time>(?:\\d*\\.)?\\d+))?)?\\s*\\)"


static func get_type() -> String:
	return "Choice"


# private ----------------------------------------------------------------

func _on_choice_changed(text: String) -> void:
	text_changed = true


func _on_choice_end_edit(control: LineEdit) -> void:
	if !text_changed:
		return
	var text = control.text
	if text != "":
		if control.get_position_in_parent() == box.get_child_count() - 1:
			add()
	elif box.get_child_count() > 1:
		_remove_choice(control)
	_update_text()


func _remove_choice(control) -> void:
	box.remove_child(control)
	control.queue_free()
	event.remove_next_entry("%dchoice%d" % [get_position_in_parent(), box.get_child_count()])


func _update_text() -> void:
	var choices := []
	for i in box.get_child_count() - 1:
		choices.append(box.get_child(i).text.c_escape())
	set_line("choice([\"%s\"], %f)" % ['", "'.join(choices), time.value])


func _add_time_control() -> void:
	time.prefix = "Time:"
	time.suffix = "s"
	time.value = int(re_match.get_string("time"))
	time.connect("value_changed", self, "_on_time_changed")
	bottom_box.add_child(time)


func _on_time_changed(_value: float) -> void:
	_update_text()


func _update_size() -> void:
	var size = box.margin_top - box.margin_bottom
	for i in box.get_children():
		size += i.rect_size.y
	size += box.get_constant("separation", "") * (box.get_child_count() - 1)
	rect_min_size.y = size
	rect_size.y = size

