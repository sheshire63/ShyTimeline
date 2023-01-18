tool
extends Resource
class_name Timeline

signal connections_changed # used to inform the editor that the slots have changed

export var events: Dictionary = {}
export var actors := {}
export var variables := {}
export var editor_pos := Vector2.ZERO
export var editor_zoom := 1.0


# public ---------------------------------------------------------

func add_event(event: Event) -> void:
	assert(event)
	var name = "Event"
	var c = 1
	while name in events:
		name = "Event%03d" % c
		c+= 1
	events[name] = event
	emit_changed()


func remove_event(event: Event) -> void:
	var key = events.values().find(event)
	if key:
		key = events.keys()[key]
		events.erase(key)
		emit_changed()


func get_event(name: String) -> Event:
	return events.get(name)


func change_event_name(old, new) -> bool:
	if new in events:
		return false
	var event: Event = events[old]
	events.erase(old)
	events[new] = event

	for i in events:
		events[i].replace_next_event(old, new)

	event.emit_changed()
	emit_changed()
	return true


func find_event_name(event) -> String:
	var pos = events.values().find(event)
	if pos >= 0:
		return events.keys()[pos]
	printt("event not in Timeline:", event)
	return ""


func update_nexts() -> void:
	emit_signal("connections_changed")
