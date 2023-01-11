tool
extends Control

const folder := "res://addons/Timeline/Edits/"

# : Timeline # definging timeline as type causes this to be null -.-
var timeline setget _set_timeline; func _set_timeline(new) -> void:
	clear()
	event = null
	timeline = new
	visible = false

var event: Event setget _set_event; func _set_event(new):
	if event and event.is_connected("changed", self, "setup"):
		event.disconnect("changed", self, "setup")
	event = new
	if !event:
		clear()
		return
	event.connect("changed", self, "setup")
	setup()
	visible = true

var types := {}

onready var box := $Scroll/Edits
onready var menu := $AddMenu
onready var add_button := $Toolbar/Add
onready var name_edit := $NameLine
var code_edit := preload("res://addons/Timeline/Edits/Code.tscn")

func _ready() -> void:
	assert(box)
	load_types()
	visible = false


# public ----------------------------------------------------------------

func clear() -> void:
	for i in box.get_children():
		box.remove_child(i)
		i.queue_free()


func setup() -> void:
	assert(box)
	clear()
	assert(event and timeline)
	name_edit.text = timeline.find_event_name(event)
	for line in event.lines:
		var type: String = line.left(line.find("("))
		load_element(type)


func add_element(type) -> void:
	if !event:
		print("No event selected")
		return
	event.add_line("%s()" % type.to_lower())
	# the change in event causes a refresh


func load_element(type: String) -> void:
	var element = types[type].instance() if type in types else code_edit.instance()
	add_edit(element)


func add_edit(edit: EventEdit) -> void:
	assert(event)
	edit.event = event
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
	assert(event and timeline)
	var old = timeline.find_event_name(event)
	if !timeline.change_event_name(old, new):
		name_edit.text = old


func _on_NameLine_text_entered(new_text: String) -> void:
	_change_node_name(new_text)
