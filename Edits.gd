tool
extends Control

#signal request_rename(event, new)


const folder := "res://addons/ShyTimeline/Edits/"

var timeline: Timeline
var event: Event
var types := {}

onready var box := $Scroll/Edits
onready var menu := $AddMenu
onready var add_button := $Toolbar/Add
onready var name_edit := $NameLine
var code_edit := preload("res://addons/ShyTimeline/Edits/Code.tscn")


func _ready() -> void:
	assert(box)
	load_types()
	visible = false


# public ----------------------------------------------------------------

func clear() -> void:
	for i in box.get_children():
		box.remove_child(i)
		i.queue_free()
	visible = false


func setup() -> void:
	clear()
	name_edit.text = timeline.find_event_name(event)
	for i in event.editor_data:
		load_element(i.type)


func edit_event(_event: Event, _timeline: Timeline) -> void:
	assert(_timeline and _event)
	clear()
	timeline = _timeline
	event = _event
	setup()
	visible = true


func add_element(type) -> void:
	if !event:
		print("No event selected")
		return
	event.editor_data.append({"type": type})
	load_element(type)

func load_element(type: String) -> void:
	var element = types[type].instance() if type in types else code_edit.instance()
	add_edit(element)


func add_edit(edit: EventEdit) -> void:
	assert(event)
	edit.event = event
	edit.timeline = timeline
	box.add_child(edit)


func load_types() -> void:
	var dir = Directory.new()
	if dir.open(folder) == OK:
		dir.list_dir_begin(true)
		var next = dir.get_next()
		while next != "":
			var element = load(folder + "%s" % next)
			if element and element is PackedScene:
				types[next.get_basename().to_lower()] = element
			next = dir.get_next()

	menu.clear()
	for i in types:
		menu.add_item(i.capitalize())


# private ---------------------------------------------------------------------

func _on_Add_pressed() -> void:
	menu.popup(Rect2(add_button.get_global_rect().end, menu.rect_size))


func _on_AddMenu_index_pressed(index: int) -> void:
	add_element(types.keys()[index])


func _change_node_name(new: String) -> void:
	#emit_signal("request_rename", event, new)
	assert(event and timeline)
	var old = timeline.find_event_name(event)
	if !timeline.change_event_name(old, new):
		name_edit.text = old


func _on_NameLine_text_entered(new_text: String) -> void:
	_change_node_name(new_text)

#todo change the way we handle timeline and event
#	make a function that takes them as value and set the event up

