tool
extends EditorPlugin


var editor := preload("res://addons/ShyTimeline/Editor.tscn").instance()
var last_object
var is_loading := false


func _enter_tree() -> void:
	editor.visible = false
	get_editor_interface().get_editor_viewport().add_child(editor)
	editor.connect("request_save", self, "save_data")
	editor.connect("request_inspect", get_editor_interface(), "inspect_object")


func _exit_tree() -> void:
	pass


func has_main_screen() -> bool:
	return true


func get_plugin_name() -> String:
	return "Timeline"


func handles(object: Object) -> bool:
	return object is TimelineHandler


func make_visible(visible: bool) -> void:
	editor.visible = visible


func edit(object: Object) -> void:
	if object != last_object:
		if last_object:
			save_data(editor.timeline)
		is_loading = true
		editor.load_data(object.timeline)
		last_object = object
		is_loading = false


func save_data(timeline: ShyTimeline) -> void:
	if !is_loading and is_instance_valid(last_object) and timeline:
		last_object.timeline = timeline
		if timeline.resource_path:
			ResourceSaver.save(timeline.resource_path, timeline)

