tool
extends Control


signal request_save(timeline)
signal request_inspect(object)


onready var graph := $HSplitContainer/TimelineEditor
onready var actor_edit := $HSplitContainer/TabContainer/Actors
onready var variable_edit := $HSplitContainer/TabContainer/Vars

var timeline := ShyTimeline.new() setget _set_timeline;func _set_timeline(new):
	timeline = new
	if graph:
		graph.timeline = timeline
	if actor_edit:
		actor_edit.timeline = timeline
	if variable_edit:
		variable_edit.timeline = timeline
var variables := {}

var undo := UndoRedo.new()


func _ready() -> void:
	graph.undo = undo
	graph.timeline = timeline
	actor_edit.undo = undo
	actor_edit.timeline = timeline
	variable_edit.timeline = timeline
	undo.connect("version_changed", self, "save_data")
	actor_edit.connect("request_inspect", self, "inspect_object")
	graph.connect("node_selected", self, "_on_node_selected")
	variable_edit.connect("request_save", self, "save_data")
	variable_edit.connect("variables_changed", self, "update_nodes")
	actor_edit.connect("actors_changed", self, "update_nodes")


func save_data() -> void:
	timeline.graph_data = graph.save_data()
	timeline.nodes = graph.save_nodes()
	timeline.actors = actor_edit.save_data()
	timeline.variables = variable_edit.save_data()
	emit_signal("request_save", timeline)


func load_data(data: ShyTimeline) -> void:
	undo.clear_history()
	graph.load_data(data.graph_data)
	self.timeline = data


func inspect_object(object) -> void:
	emit_signal("request_inspect", object)


func get_actors() -> Dictionary:
	return actor_edit.actors


func update_nodes() -> void:
	graph.update_nodes(timeline)


func _on_node_selected(node) -> void:
	emit_signal("request_inspect", node.data)
