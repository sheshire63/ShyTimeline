tool
extends Panel

class_name EventEdit



export var has_slot_button := true setget _set_has_slot_button; func _set_has_slot_button(new) -> void:
	has_slot_button = new
	setup()

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
	setup()


func clear() -> void:
	for i in get_children():
		if !i.owner:
			remove_child(i)
			i.queue_free()


# called once on start and in editor on button change
func setup() -> void:
	clear()
	add_remove_button()

	# add box if have buttons for it
	if has_slot_button:
		bottom_box = HBoxContainer.new()
		bottom_box.anchor_top = 1.0
		bottom_box.anchor_right = 1.0
		bottom_box.margin_top = - 40.0
		add_child(bottom_box)
	else:
		bottom_box = null

	if has_slot_button:
		slot_button = CheckButton.new()
		slot_button.text = "Next Slot"
		slot_button.connect("toggled", self, "_on_slot_toggled")
		bottom_box.add_child(slot_button)
	else:
		slot_button = null


func add_remove_button() -> void:
	remove_button = Button.new()
	remove_button.text = "x"
	remove_button.connect("pressed", self, "remove")
	add_child(remove_button)
	remove_button.anchor_left = 1.0
	remove_button.margin_left = - remove_button.rect_size.x


func remove() -> void:
	var pos = get_position_in_parent()
	get_parent().remove_child(self)
	event.remove_line(pos)
	queue_free()


func get_line_number() -> int:
	return get_position_in_parent()


# private ----------------------------------------

#todo we need a way to sort the next entrys if we move them in the list and we want next to be at the end
func _on_slot_toggled(show: bool) -> void:
	if show:
		event.add_next_entry(get_line_number())
	else:
		event.remove_next_entry(get_line_number())
