tool
extends EditorPlugin


var editor: Control = preload("res://addons/Timeline/Editor.tscn").instance()


func _enter_tree() -> void:
	if editor:
		get_editor_interface().get_editor_viewport().add_child(editor)
		editor.visible = false
		editor.connect("request_inspect", get_editor_interface(), "inspect_object")


func _exit_tree() -> void:
	editor.queue_free()


func has_main_screen() -> bool:
	return true


func get_plugin_name() -> String:
	return "Timeline"


func handles(object: Object) -> bool:
	#return false
	return object is BaseHandler


func edit(object: Object) -> void:
	if !object.timeline:
		object.timeline = Timeline.new()
	editor.timeline = object.timeline


func make_visible(visible: bool) -> void:
	editor.visible = visible
