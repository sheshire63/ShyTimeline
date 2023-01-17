tool
extends Control

signal request_inspect(item)

onready var graph := $HSplitContainer/TimelineEdit
onready var sub_edits := $HSplitContainer/Edit
onready var save_dialog := $Toolbar/Save/SaveFileDialog


export onready var timeline: Resource setget _set_timeline;func _set_timeline(new):
	printt("editor", timeline, "->", new)
	timeline = new
	sub_edits.clear()
	graph.timeline = timeline


func _ready() -> void:
	print("editor ready")
	graph.connect("request_edit", self, "edit")
	graph.connect("node_unselected", self, "_on_node_unselected", [], CONNECT_DEFERRED)


func add_event() -> void:
	if timeline:
		graph.add()
	else:
		print("No timeline selected")


func edit(event: Event) -> void:
	sub_edits.edit_event(event, timeline)
	emit_signal("request_inspect", event)
	#todo also edit all selected in Inspector?
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
	else:
		print("%s is not a Timeline." % path)


func _on_Save_pressed() -> void:
	if timeline:
		save_dialog.popup_centered(save_dialog.rect_size)
	else:
		print("No Timeline set")


func _on_SaveFileDialog_file_selected(path: String) -> void:
	var err = ResourceSaver.save(path, timeline)
	if err != OK:
		print("error: '%s'failed to save timeline to '%s'" % [err, path])
