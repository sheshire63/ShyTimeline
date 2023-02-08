tool
extends Control

signal request_inspect(character)

const CharControl := preload("res://addons/ShyTimeline/CharControl.tscn")

onready var load_dialog := $Load/FileDialog
onready var box := $VBoxContainer
onready var new_button := $New
onready var load_button := $Load

var timeline: Timeline setget _set_timeline; func _set_timeline(new: Timeline) -> void:
	if timeline == new:
		return
	clear()
	timeline = new
	if timeline:
		new_button.disabled = false
		load_button.disabled = false
		for i in timeline.actors:
			add(timeline.actors[i], i)
	else:
		new_button.disabled = true
		load_button.disabled = true


func clear() -> void:
	for i in box.get_children():
		i.queue_free()


func add(actor: Actor, id := "") -> void:
	if !actor:
		return
	if !timeline:
		print("creating new timeline")
		timeline = Timeline.new()
	if not id in timeline.actors:
		timeline.actors[id] = actor
	var control = CharControl.instance()
	box.add_child(control)
	control.actor = actor
	control.set_name(id)
	control.connect("request_name_change", self, "_on_char_name_changed", [control])
	control.connect("on_delete", self, "_on_char_delete")
	control.connect("pressed", self, "_on_char_inspect", [actor])


func _on_Load_pressed() -> void:
	load_dialog.popup_centered(load_dialog.rect_size)


func _on_FileDialog_files_selected(paths: PoolStringArray) -> void:
	for path in paths:
		var actor = load(path)
		if actor and actor is Actor:
			add(actor)


func _on_New_pressed() -> void:
	add(Actor.new())


func _on_char_name_changed(from: String, to: String, control: Control) -> void:
	if not to in timeline.actors:
		timeline.actors[to] = control.actor
		if from in timeline.actors:
			timeline.actors.erase(from)
		control.set_name(to)


func _on_char_delete(name) -> void:
	timeline.actors.erase(name)


func _on_char_inspect(actor: Actor) -> void:
	emit_signal("request_inspect", actor)
