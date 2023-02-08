tool
extends EditorPlugin


var editor: Control = preload("res://addons/ShyTimeline/Editor.tscn").instance()
var actor: Control = preload("res://addons/ShyTimeline/CharEdit.tscn").instance()
var variable: Control = preload("res://addons/ShyTimeline/VariableEdit.tscn").instance()


func _enter_tree() -> void:
	if editor:
		get_editor_interface().get_editor_viewport().add_child(editor)
		editor.visible = false
		editor.connect("request_inspect", self, "_on_request_inspect")
	if actor:
		add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, actor)
		actor.connect("request_inspect", get_editor_interface(), "inspect_object")
	if variable:
		add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, variable)


func _exit_tree() -> void:
	if is_instance_valid(editor):
		editor.queue_free()
	if is_instance_valid(actor):
		actor.queue_free()
	if is_instance_valid(variable):
		variable.queue_free()
	

func has_main_screen() -> bool:
	return true


func get_plugin_name() -> String:
	return "Timeline"


func handles(object: Object) -> bool:
	#return false # this is to better debug the handler
	return object is BaseHandler


func edit(object: Object) -> void:
	var timeline = object.timeline
	if !timeline:
		timeline = Timeline.new()
		object.timeline = timeline
	editor.timeline = timeline
	actor.timeline = timeline
	variable.timeline = timeline


func make_visible(visible: bool) -> void:
	editor.visible = visible


func _on_request_inspect(object: Object) -> void:
	if object:
		get_editor_interface().inspect_object(object)
	if object is Timeline:
		edit(object)
