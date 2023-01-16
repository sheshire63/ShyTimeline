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


var event: Event
var timeline: Timeline
var slot_button: CheckButton
var remove_button: Button
var bottom_box: HBoxContainer
var re_match: RegExMatch


#todo we need a signal/function to remove the next entrys from event if we remove the line

func _ready() -> void:
	if !event:
		print("no event set in %s creating new event" % self)
		self.event = Event.new()
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_SHRINK_CENTER
	rect_min_size.y = 128
	_add_label()
	_add_remove_button()
	_add_bottom_box()
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


func get_line(pos := -1) -> String:
	if has_line(pos):
		return event.lines[get_line_number(pos)]
	else:
		return ""


func set_line(line: String) -> void:
	if has_line():
		event.lines[get_line_number()] = line
	else:
		event.lines.append(line)


func has_line(pos:= -1) -> bool:
	return event.lines.size() > get_line_number(pos)


func try_parse(pos := -1) -> bool:
	var re = RegEx.new()
	var err = re.compile(get_regex())
	assert(err == OK)
	re_match = re.search(get_line(pos))
	return re_match != null


#virtual ----------------------------------------------------------------

static func get_regex() -> String:
	return "[\\w\\W]*"


static func get_type() -> String:
	return "Error"


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
	remove_button.margin_left = - remove_button.rect_size.x


func _add_label() -> void:
	var label = Label.new()
	label.anchor_right = 1.0
	label.margin_left = 16.0
	label.margin_top = 16.0
	label.margin_right = -16.0
	label.margin_bottom = 40.0 - 16.0
	label.text = get_type()
	label.align = label.ALIGN_CENTER
	label.valign = label.ALIGN_CENTER
	add_child(label)
