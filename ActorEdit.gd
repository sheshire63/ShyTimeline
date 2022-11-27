tool
extends Control

signal request_inspect(actor)
signal actors_changed

onready var new_actor_popup := $NewActor/ActorPopup
onready var new_actor_line := $NewActor/ActorPopup/LineEdit
onready var actor_box := $Scroll/Actors


var undo := UndoRedo.new()
var timeline = ShyTimeline.new() setget _set_timeline; func _set_timeline(new):
	timeline = new
	undo.clear_history()
	setup()
var _actor_controls := {}


func _ready() -> void:
	setup()


func setup() -> void:
	_clear_actors()
	for i in timeline.actors:
		_add_actor(i, timeline.actors[i])


func save_data() -> Dictionary:
	return timeline.actors


func add_actor(name , actor: Actor) -> void:
	if name in timeline.actors:
		print("actor %s already exists"%[name])
		return
	undo.create_action("New Actor %s"%[name])
	undo.add_do_reference(actor)
	undo.add_do_method(self, "_add_actor", name, actor)
	undo.add_undo_method(self, "_remove_actor", name)
	undo.commit_action()
	emit_signal("actors_changed")


func inspect_actor(actor: Actor) -> void:
	emit_signal("request_inspect", actor)


func _on_NewActor_pressed() -> void:
	new_actor_line.text = "actor"
	new_actor_popup.popup(Rect2(get_global_mouse_position(), new_actor_line.rect_size))
	new_actor_line.grab_focus()
	new_actor_line.select_all()


func _on_ActorPopup_popup_hide() -> void:
	var name = new_actor_line.text.validate_node_name()
	new_actor_line.release_focus()
	add_actor(name, Actor.new())


func _on_LineEdit_text_entered(new_text:String) -> void:
	new_actor_popup.hide()


func _add_actor(name: String, actor: Actor) -> void:
	timeline.actors[name] = actor
	_add_actor_control(name, actor)


func _remove_actor(name: String) -> void:
	timeline.actors.erase(name)
	_remove_actor_control(name)


func _add_actor_control(name: String, actor: Actor) -> void:
	var button = Button.new()
	button.text = name
	button.connect("pressed", self, "inspect_actor", [actor])
	actor_box.add_child(button)
	_actor_controls[name] = button


func _remove_actor_control(name: String) -> void:
	actor_box.remove_child(_actor_controls[name])
	_actor_controls[name].queue_free()
	_actor_controls.erase(name)


func _clear_actors() -> void:
	for i in _actor_controls:
		actor_box.remove_child(_actor_controls[i])
		_actor_controls[i].queue_free()
	_actor_controls = {}