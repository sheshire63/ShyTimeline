tool
extends EventEdit

onready var box := $VBoxContainer
onready var add_line_line := $add_line

var time := SpinBox.new()
var line_scene := preload("res://addons/ShyTimeline/ItemEdit.tscn")
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


# public ----------------------------------------------------------------

func add(choice:= "") -> void:
	var new = line_scene.instance()
	box.add_child(new)
	new.set_text(choice)
	new.connect("request_delete", self, "_remove_segment", [new])
	new.connect("request_save", self, "_update_text")
	new.connect("request_move_up", self, "_move_segment_up", [new])
	new.connect("request_move_down", self, "_move_segment_down", [new])
	call_deferred("_update_size")


# static/overrides ----------------------------------------------------------------

static func get_regex() -> String:
	return "choice\\(\\s*(?:\\[(?<choices>.*?)\\](?:\\s*,\\s*(?<time>(?:\\d*\\.)?\\d+))?)?\\s*\\)"


static func get_type() -> String:
	return "Choice"


# private ----------------------------------------------------------------


func _update_text() -> void:
	var choices := []
	for i in box.get_children():
		choices.append(i.get_text().c_escape())
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
	var size = box.margin_top + abs(box.margin_bottom)
	size += box.rect_size.y
	rect_min_size.y = size
	rect_size.y = size


func _remove_segment(line: Control) -> void:
	event.remove_next_entry("%dchoice%d" % [get_position_in_parent(), line.get_position_in_parent()])
	box.remove_child(line)
	line.queue_free()


func _move_segment_down(line: Control) -> void:
	_move_segment(line, line.get_position_in_parent() + 1)


func _move_segment_up(line: Control) -> void:
	_move_segment(line, line.get_position_in_parent() - 1)


func _move_segment(line: Control, to: int) -> void:
	if to >= 0 and to < box.get_child_count():
		event.swtich_next_entry(
			"%dchoice%d" % [get_position_in_parent(), line.get_position_in_parent()],
			"%dchoice%d" % [get_position_in_parent(), to])
		box.move_child(line, to)
		_update_text()


func _on_add_line_text_changed(new_text: String) -> void:
	add(new_text)
	add_line_line.text = ""
