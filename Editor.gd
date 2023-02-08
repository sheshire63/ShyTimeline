tool
extends Control

signal request_inspect(item)

onready var graph := $HSplitContainer/TimelineEdit
onready var sub_edits := $HSplitContainer/Edit
onready var save_dialog := $Toolbar/SaveTo/SaveFileDialog


export onready var timeline: Resource setget _set_timeline;func _set_timeline(new):
	if timeline == new:
		return
	if timeline and timeline.is_connected("changed", self, "_on_timeline_changed"):
		timeline.disconnect("changed", self, "_on_timeline_changed")
	if new:
		new.connect("changed", self, "_on_timeline_changed")

	timeline = new
	sub_edits.clear()
	graph.timeline = timeline




func _ready() -> void:
	graph.connect("request_edit", self, "edit")
	graph.connect("node_unselected", self, "_on_node_unselected", [], CONNECT_DEFERRED)


func add_event() -> void:
	if timeline:
		graph.add()
	else:
		print("No timeline selected")


func edit(event: Event) -> void:
	sub_edits.edit_event(event, timeline)
	_request_inspect(event)
	#todo also edit all selected in Inspector?
	#	-is this possible? the engine can, but there is no function for it
	# -> use property list to have not all properties in inpector


# private ----------------------------------------------------------------

func _on_Add_pressed() -> void:
	add_event()


func _on_node_unselected(_node) -> void:
	if graph.selected_nodes.empty():
		sub_edits.visible = false


func _on_FileDialog_file_selected(path: String) -> void:
	var file = ResourceLoader.load(path)
	if file is Timeline:
		self.timeline = file
		emit_signal("request_inspect", timeline)
	else:
		print("%s is not a Timeline." % path)


func _on_Save_pressed() -> void:
	sub_edits.compile()
	timeline.save()


func _on_SaveFileDialog_file_selected(path: String) -> void:
	sub_edits.compile()
	timeline.save(path)


func _on_timeline_changed() -> void:
	sub_edits.clear()


func _on_New_pressed() -> void:
	self.timeline = Timeline.new()
	emit_signal("request_inspect", timeline)


func _request_inspect(object: Object) -> void:
	emit_signal("request_inspect", object)


func _on_SaveTo_pressed() -> void:
	if timeline:
		save_dialog.popup_centered(save_dialog.rect_size)
	else:
		print("No Timeline set")
