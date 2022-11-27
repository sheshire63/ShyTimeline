tool
extends ShyGraphNode

class_name ShyTimelineNode


var undo := UndoRedo.new()
var data := NodeData.new()
var timeline := ShyTimeline.new() setget _set_timeline;func _set_timeline(new):
		timeline = new
var next := []

func _ready() -> void:
	connect("connected", self, "_on_connected")
	connect("disconnected", self, "_on_disconnected")


func _on_connected(slot: int, node: String, node_slot: int) -> void:
	if slots[slot].name == "Next":
		next.append(node)


func _on_disconnected(slot: int, node: String, node_slot: int) -> void:
	if slots[slot].name == "Next":
		next.erase(node)


func get_event() -> Dictionary:# todo move to data
	var event = data.save_data()
	event.next = next
	return event


static func lex(line: String) -> Dictionary:
	line += "}"
	return _lex([line], true)


static func _lex(line: Array, is_string := true) -> Dictionary: # needs a string inside the line array
	if !line or not line[0] is String:
		return {}
	var lex := ""
	var layer := "" # only one symbol ? another would be in the next recursion
	var section := ""
	var result := {"value": []}
	var value_parts := []
	var entry := {}
	var skip := false
	while line[0] != "":
		var letter = line[0][0]
		line[0] = line[0].right(1)

		var add_letter = false
		if skip == true:# escaped character
			skip = false
		else:
			if is_string or layer in ["'", '"']:
				match letter:
					"\\":
						skip = true
					"{":
						if lex:
							value_parts.append(lex)
							lex = ""
						value_parts.append(_lex(line, false))
					"'", '"':
						add_letter = true
						if layer == letter:
							layer = ""
						else:
							layer  = letter
					"}":
						if is_string:
							value_parts.append(lex)
							result.value = value_parts
							return result
						continue
					_:
						add_letter = true
			else:
				match letter:
					"{":
						if lex:
							value_parts.append(lex)
							lex = ""
						value_parts.append(_lex(line, false))
					"?":
						section = letter
						continue
					",", "}", ":", "?", "!":
						if lex:
							value_parts.append(lex)
							lex = ""
						match section:
							"?":
								entry.condition = value_parts
							"":
								entry.value = value_parts
							":":
								entry.weight = value_parts
							"!":
								entry.next = value_parts
						value_parts = []
						continue
					":", "!":
						section = letter
					"?", ",", "}" :
						section = ""
						continue
					"}", ",":
						result.value.append([entry])
						entry = {}
						continue
					"}":
						return result
					",", "}", ":", "?", "!":
						pass
					_:
						add_letter = true
		if add_letter:
			lex += letter
	return {"value": [lex]}


func _save_data() -> Dictionary:
	var save = data.save_data()
	save.next = next
	return save


func _load_data(_data:= {}) -> void:
	data.load_data(_data)
	next = _data.get("next", next)


func _delete() -> void:
	pass


func _copy(copy) -> void:#if you need to set somthing in the copy.
	pass
