tool
extends Panel

class_name EventEdit



export var show_bottom_box := true setget _set_show_bottom_box; func _set_show_bottom_box(new) -> void:
	show_bottom_box = new
	bottom_box.visible = new
export var show_slot_button := true setget _set_show_slot_button; func _set_show_slot_button(new) -> void:
	show_slot_button = new
	if show_slot_button:
		self.show_bottom_box = true
	slot_button.visible = true


var event: Event
var slot_button: CheckButton
var remove_button: Button
var bottom_box: HBoxContainer



func _ready() -> void:
	if !event:
		print("no event set in %s creating new event" % self)
		self.event = Event.new()
	size_flags_horizontal = SIZE_EXPAND_FILL
	rect_min_size.y = 128
	_add_remove_button()
	_add_bottom_box()
	_add_slot_button()

	call_deferred("_connect_resize_on_childs")


# public ----------------------------------------------------------------

func remove() -> void:
	var pos = get_position_in_parent()
	get_parent().remove_child(self)
	event.remove_line(pos)
	queue_free()


func get_line_number() -> int:
	return get_position_in_parent()


func get_line() -> String:
	return event.lines[get_line_number()]


func set_line(line: String) -> void:
	if has_line():
		event.lines[get_line_number()] = line
	else:
		event.lines.append(line)


func has_line() -> bool:
	return event.lines.size() > get_line_number()


# private ----------------------------------------

#todo we need a way to sort the next entrys if we move them in the list and we want next to be at the end
func _on_slot_toggled(show: bool) -> void:
	if show:
		event.add_next_entry(get_line_number())
	else:
		event.remove_next_entry(get_line_number())


func _connect_resize_on_childs() -> void:
	for i in get_children():
		if i is Container:
			i.connect("sort_children", self, "_update_size")#todo fix shrinking not working
		i.connect("resized", self, "_update_size")


func _update_size() -> void:
	var min_size = 0.0
	for i in get_children():
		var size = i.rect_size.y + i.margin_top - i.margin_bottom
		size /= 1 - min(i.anchor_top, 1 - i.anchor_bottom)
		min_size = max(min_size, size)
	rect_size.y = min_size
	update()


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
