tool
extends GraphEdit
class_name ShyGraphEdit

enum TYPES {FLOW}
var valid_connections = {
	TYPES.FLOW: [TYPES.FLOW],
}


signal request_edit(event)



var nodes := {0: ShyTimelineNode}
var timeline: Timeline setget _set_timeline; func _set_timeline(new) -> void:
	if timeline and timeline.is_connected("connections_changed", self, "setup"):
		timeline.disconnect("connections_changed", self, "setup")
	timeline = new
	timeline.connect("connections_changed", self, "setup")
	setup()
var undo := UndoRedo.new()
var selected_nodes := []

var _connect_to := {}

onready var node_menu := $NodeMenu




# public ----------------------------------------------------------------

# loads a node and creates a event for it if no event is submitted
func add(node = null, event:Event = null) -> void:
	assert(timeline)
	if !node:
		node = ShyTimelineNode.new()

	if event:
		node.offset = event.editor_position
	else:
		event = Event.new()
		timeline.add_event(event)
		node.offset = get_offset_at_position(get_local_mouse_position())#todo clamp the offset so that the node is in the current view

	node.event = event
	node.timeline = timeline

	add_child(node, true)

	# load connection from event
	for i in node.event.next:
		var from = node.name
		var from_slot = node.event.next.keys().find(i)
		for j in node.event.next[i]:
			connect_node(node.name, from_slot, j, 0)


func setup() -> void:
	clear()
	for event in timeline.events:
		add(null, timeline.events[event])


func clear() -> void:
	clear_connections()
	for i in get_children():
		if i is GraphNode:
			remove_child(i)
			i.queue_free()


func get_offset_at_position(position: Vector2) -> Vector2:
	return scroll_offset + (position * zoom)


# on_events ----------------------------------------------------------------

func _on_TimelineEdit_connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	_connect_node(from, from_slot, to, to_slot)


func _on_TimelineEdit_connection_from_empty(to: String, to_slot: int, release_position: Vector2) -> void:
	_connect_to = {
		"to": to,
		"to_port": to_slot,
	}
	node_menu.popup(Rect2(release_position, node_menu.rect_size))


func _on_TimelineEdit_connection_to_empty(from: String, from_slot: int, release_position: Vector2) -> void:
	_connect_to = {
		"from": from,
		"from_port": from_slot,
	}
	node_menu.popup(Rect2(release_position, node_menu.rect_size))


func _on_TimelineEdit_copy_nodes_request() -> void:
	pass # Replace with function body.


func _on_TimelineEdit_delete_nodes_request(nodes: Array) -> void:
	pass # Replace with function body.


func _on_TimelineEdit_disconnection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	_disconnect_node(from, from_slot, to, to_slot)


func _on_TimelineEdit_duplicate_nodes_request() -> void:
	pass # Replace with function body.


func _on_TimelineEdit_paste_nodes_request() -> void:
	pass # Replace with function body.


func _on_TimelineEdit_popup_request(position: Vector2) -> void:
	node_menu.popup(Rect2(position, node_menu.rect_size))


func _on_TimelineEdit_node_selected(node: Node) -> void:
	selected_nodes.append(node)
	emit_signal("request_edit", node.event)


func _on_TimelineEdit_node_unselected(node: Node) -> void:
	selected_nodes.erase(node)


func _on_NodeMenu_id_pressed(id: int) -> void:
	if !timeline:
		print("No timeline selected")
		return

	var new: GraphNode = nodes[id].new()
	add(new)

	# try to create a connection if we created the node by connecting to empty
	if "to" in _connect_to:
		var to_type = get_node(_connect_to.to).get_port_type_left(_connect_to.to_port)
		for i in new.get_port_count_right():
			var from_type = new.get_port_type_right(i)
			if _is_connection_valid(from_type, to_type):
				_connect_node(new.name, i, _connect_to.to, _connect_to.to_port)
	elif "from" in _connect_to:
		var from_type = get_node(_connect_to.from).get_port_type(_connect_to.from_port)
		for i in new.get_port_count_left():
			var to_type = new.get_port_type_left(i)
			if _is_connection_valid(from_type, to_type):
				_connect_node(_connect_to.fro, _connect_to.from_port, new.name, i)


func _on_PopupMenu_popup_hide() -> void:
	_connect_to = {}


# private ----------------------------------------------------------------

func _is_connection_valid(from_type: int, to_type: int) -> bool:
	return to_type in valid_connections[from_type]


func _connect_node(from: String, from_slot: int, to: String, to_slot: int) -> void:
	var from_node := get_node(from)
	var to_node := get_node(to)
	var from_type: int = from_node.get_slot_type_left(from_slot)
	var to_type: int = to_node.get_slot_type_right(to_slot)
	if _is_connection_valid(from_type, to_type):
		connect_node(from, from_slot, to, to_slot)
	#from_node.link_out(from_slot, to, to_slot)
	#to_node.link_in(to_slot, from, from_slot)
	get_node(from).event.add_to_next_entry(from_slot, to, to_slot)



func _disconnect_node(from: String, from_slot: int, to: String, to_slot: int) -> void:
	disconnect_node(from, from_slot, to, to_slot)
	var from_node := get_node(from)
	var to_node := get_node(to)
	#from_node.unlink_out(from_slot, to, to_slot)
	#to_node.unlink_in(to_slot, from, from_slot)
	get_node(from).event.remove_from_next_entry(from_slot, to, to_slot)
