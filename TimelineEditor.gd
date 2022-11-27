tool
extends ShyGraphEdit

var timeline: ShyTimeline setget _set_timeline; func _set_timeline(new):
	timeline = new
	update_nodes(new)


func _ready() -> void:
	connect("node_created", self, "_on_node_created")


func save_nodes() -> Dictionary:
	var result = {}
	for i in get_children():
		if i is ShyTimelineNode:
			result[i.name] = i.get_event()
	return result


func _set_undo(new: UndoRedo) -> void:
	undo = new
	for i in get_children():
		if i is ShyTimelineNode:
			i.undo = undo


func _on_node_created(node) -> void:
	node.undo = undo
	node.timeline = timeline


func update_nodes(timeline) -> void:
	for i in get_children():
		if i is ShyTimelineNode:
			i.timeline = timeline
