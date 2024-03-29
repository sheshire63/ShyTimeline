tool
extends Panel

class_name EventEdit



export var show_bottom_box := true setget _set_show_bottom_box; func _set_show_bottom_box(new) -> void:
	show_bottom_box = new
	if bottom_box:
		bottom_box.visible = new
export var show_slot_button := true setget _set_show_slot_button; func _set_show_slot_button(new) -> void:
	show_slot_button = new
	if show_slot_button:
		self.show_bottom_box = true
	if slot_button:
		slot_button.visible = true


var event: Resource
var timeline: Timeline

var label: Label
var slot_button: CheckButton
var remove_button: Button
var move_up_button: Button
var move_down_button: Button
var bottom_box: HBoxContainer


#todo we need a signal/function to remove the next entrys from event if we remove the line

func _ready() -> void:
	if !event:
		print("no event set in %s creating new event for debug purpose" % self)
		self.event = Event.new()
		event.editor_data.append({})
	if !timeline:
		print("no timeline set creating new one for debug purpose")
		timeline = Timeline.new()
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_SHRINK_CENTER
	_add_label()
	_add_remove_button()
	_add_bottom_box()
	_add_move_buttons()
	_add_slot_button()


# public ----------------------------------------------------------------

func remove() -> void:
	var pos = get_position_in_parent()
	get_parent().remove_child(self)
	event.remove_line(pos)
	queue_free()


func get_line_number(pos := -1) -> int:
	if pos < 0:
		pos = get_position_in_parent()
	return pos


func get_data(pos := -1) -> Dictionary:
	pos = get_line_number(pos)
	assert(has_line(pos))
	return event.editor_data[pos]


func has_line(pos := -1) -> bool:
	return pos < event.editor_data.size()


func save_to_line() -> void:
	if has_line():
		event.lines[get_line_number()] = get_code()
	else:
		event.lines.append(get_code())


func try_parse(pos := -1) -> bool:
	var re = RegEx.new()
	var err = re.compile(get_regex())
	assert(err == OK)
	var re_match = re.search(get_line(pos))
	parse(re_match)
	return re_match != null


func get_line(pos:= -1) -> String:
	if has_line(pos):
		return event.lines[pos]
	else:
		return ""


#virtual ----------------------------------------------------------------

static func get_regex() -> String:
	return "[\\w\\W]*"


static func get_type() -> String:
	return "Error"


func get_code() -> String:
	return ""


func parse(re_match: RegExMatch) -> void:
	pass


# private ----------------------------------------

#todo we need a way to sort the next entrys if we move them in the list and we want next to be at the end
func _on_slot_toggled(show: bool) -> void:
	if show:
		event.add_next_entry(get_line_number())
	else:
		event.remove_next_entry(get_line_number())
	timeline.update_nexts()


func _add_bottom_box() -> void:
	bottom_box = HBoxContainer.new()
	bottom_box.anchor_top = 1.0
	bottom_box.anchor_right = 1.0
	bottom_box.margin_top = - 40.0
	bottom_box.visible = show_bottom_box
	add_child(bottom_box)


func _add_slot_button() -> void:
	slot_button = CheckButton.new()
	slot_button.text = "Next Slot"
	slot_button.pressed = event.has_slot_entry(get_line_number())
	slot_button.connect("toggled", self, "_on_slot_toggled")
	slot_button.visible = show_slot_button
	bottom_box.add_child(slot_button)


func _add_remove_button() -> void:
	remove_button = Button.new()
	remove_button.text = "x"
	remove_button.connect("pressed", self, "remove")
	add_child(remove_button)
	remove_button.anchor_left = 1.0
	remove_button.margin_left = -40
	remove_button.margin_bottom = 40


func _add_label() -> void:
	label = Label.new()
	label.anchor_right = 1.0
	label.margin_left = 16.0
	label.margin_top = 16.0
	label.margin_right = -16.0
	label.margin_bottom = 40.0 - 16.0
	label.text = get_type()
	label.align = label.ALIGN_CENTER
	label.valign = label.ALIGN_CENTER
	add_child(label)


func _add_move_buttons() -> void:
	move_up_button = Button.new()
	move_up_button.text = "^"
	move_up_button.anchor_left = 1.0
	move_up_button.margin_left = -40
	move_up_button.margin_bottom = 80
	move_up_button.margin_top = 40
	move_up_button.connect("pressed", self, "_on_move_up_pressed")
	add_child(move_up_button)

	move_down_button = Button.new()
	move_down_button.text = "v"
	move_down_button.anchor_left = 1.0
	move_down_button.anchor_top = 1.0
	move_down_button.margin_left = -40
	move_down_button.margin_top = -40
	move_down_button.connect("pressed", self, "_on_move_down_pressed")
	add_child(move_down_button)


func _on_move_down_pressed() -> void:
	var pos = get_line_number()
	if pos < event.get_line_count() - 1:
		event.switch_lines(pos, pos + 1)
		get_parent().move_child(self, pos + 1)


func _on_move_up_pressed() -> void:
	var pos = get_line_number()
	if pos > 0:
		event.switch_lines(pos, pos - 1)
		get_parent().move_child(self, pos - 1)
