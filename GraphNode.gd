tool
extends GraphNode
class_name ShyTimelineNode


enum TYPE {FLOW,}
const COLOR := [Color.white]



var timeline: Timeline
var event: Event



func _ready() -> void:
	# if we run the node alone we create a timeline and event
	if !event:
		print("no event set in %s creating new event" % self)
		self.event = Event.new()
	if !timeline:
		print("no timeline set in %s creating new timeline" % self)
		self.timeline = Timeline.new()
		timeline.add_event(event)
	setup()
	event.connect("changed", self, "setup")
	connect("dragged", self, "_on_dragged")


# public ----------------------------------------------------------------

func clear() -> void:
	clear_all_slots()
	for child in get_children():
		remove_child(child)
		child.queue_free()


func setup() -> void:
	clear()
	assert(event and timeline)

	title = timeline.find_event_name(event)
	name = title
	show_close = true

	var in_label = Label.new()
	in_label.text = "On"
	add_child(in_label)
	#move_child(in_label, 0)
	set_slot(0, true, TYPE.FLOW, COLOR[TYPE.FLOW], false, 0, 0)

	for i in event.next:
		var label = Label.new()
		if i is int:
			label.text = "On Line %d" % i
		else:
			label.text = i
		add_child(label)
		var pos = label.get_position_in_parent()
		set_slot(pos, false, 0 ,0 , true, TYPE.FLOW, COLOR[TYPE.FLOW])
	rect_size = Vector2.ZERO # defaults to a calculated minsize


func get_port_count_left() -> int:
	var c = 0
	for i in get_child_count():
		if is_slot_enabled_left(i):
			c += 1
	return c


func get_port_count_right() -> int:
	var c = 0
	for i in get_child_count():
		if is_slot_enabled_right(i):
			c += 1
	return c


func get_port_type_left(port) -> int:
	var idx = 0
	while idx < get_child_count():
		if is_slot_enabled_left(idx):
			port -= 1
			if port < 0:
				return get_slot_type_left(idx)
		idx += 1
	return -1


func get_port_type_right(port) -> int:
	var idx = 0
	while idx < get_child_count():
		if is_slot_enabled_right(idx):
			port -= 1
			if port < 0:
				return get_slot_type_right(idx)
		idx -= 1
	return -1


# private ----------------------------------------------------------------

func _on_dragged(_from: Vector2, to: Vector2) -> void:
	assert(event)
	event.editor_position = to
