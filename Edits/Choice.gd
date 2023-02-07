tool
extends EventEdit

onready var box := $VBoxContainer
onready var add_line_line := $add_line

var time := SpinBox.new()
var line_scene := preload("res://addons/ShyTimeline/ItemEdit.tscn")
var text_changed = false


func _ready() -> void:
	_add_time_control()
	var data = get_data()
	for i in data.get("choices", []):
		add(i)


# public ----------------------------------------------------------------

func add(choice:= "") -> void:
	var new = line_scene.instance()
	box.add_child(new)
	new.set_text(choice)
	new.connect("request_delete", self, "_remove_segment", [new])
	new.connect("request_move_up", self, "_move_segment_up", [new])
	new.connect("request_move_down", self, "_move_segment_down", [new])
	new.connect("text_changed", self, "_on_choice_changed", [new])
	call_deferred("_update_size")
	add_line_line.focus_previous = get_path_to(new.line)


# static/overrides ----------------------------------------------------------------

static func get_regex() -> String:
	return "choice\\(\\s*(?:\\[(?<choices>.*?)\\](?:\\s*,\\s*(?<time>(?:\\d*\\.)?\\d+))?)?\\s*\\)"


static func get_type() -> String:
	return "Choice"


func get_code() -> String:
	var choices := []
	for i in box.get_children():
		choices.append(i.get_text().c_escape())
	return "choice([\"%s\"], %f)" % ['", "'.join(choices), time.value]


func parse(re_match: RegExMatch) -> void:
	var regex = RegEx.new()
	var err = regex.compile('[\'"](?<choice>(?:[^\\\\\'"]|(?:\\\\.))*)[\'"]')
	assert(err == OK)
	var res = regex.search_all(re_match.get_string("choices"))
	for i in res:
		add(i.get_string("choice").c_unescape())
	time.value = int(re_match.get_string("time"))



# private ----------------------------------------------------------------

func _add_time_control() -> void:
	time.prefix = "Time:"
	time.suffix = "s"
	time.value = get_data().get("time", 0.0)
	time.connect("value_changed", self, "_on_time_changed")
	bottom_box.add_child(time)


func _on_time_changed(value: float) -> void:
	get_data().time = value


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
		event.switch_next_entry(
			"%dchoice%d" % [get_position_in_parent(), line.get_position_in_parent()],
			"%dchoice%d" % [get_position_in_parent(), to])#todo move to event and check all entries starting with linenumber
		box.move_child(line, to)


func _on_add_line_text_changed(new_text: String) -> void:
	add(new_text)
	add_line_line.text = ""


func _on_choice_changed(text, edit) -> void:
	var pos = edit.get_position_in_parent()
	var data = get_data()
	if not "choices" in data:
		data.choices = []
	while pos >= data.choices.size():
		data.choices.append("")
	data.choices[pos] = text

