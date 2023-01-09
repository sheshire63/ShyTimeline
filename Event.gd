tool
extends Resource
class_name Event

# use emit_changed() to update graphNode and editView

export var lines: PoolStringArray = [] as PoolStringArray
export var actors := {} #linenumber as key
export var controls := {} #linenumber as key
export var next: Dictionary = {"next": [] as PoolStringArray} #"next", "choice[-1,..,x]", x(int for linenumber) value as poolstring array
export var editor_position := Vector2.ZERO setget _set_editor_position; func _set_editor_position(new) -> void:
	editor_position = new
	emit_changed()



func get_line(id: int) -> String:
	return lines[id]


func get_next(key: String) -> String:
	if key in next:
		return next[key]
	return ""


func get_line_size() -> int:
	return lines.size()


func get_line_count() -> int:
	return lines.size()


func add_line(line : String) -> void:
	lines.append(line)
	emit_changed()


func remove_line(line : int) -> void:
	lines.remove(line)
	emit_changed()


func set_line(text : String, id: int) -> void:
	lines[id] = text
	emit_changed()


func add_next_entry(key) -> void:
	next[key] = [] as PoolStringArray
	emit_changed()


func remove_next_entry(key) -> void:
	next.erase(key)
	emit_changed()


func swtich_next_entry(key_a, key_b) -> void:
	var a = next.get(key_a)
	var b = next.get(key_b)

	#switch
	if a != null and b != null:
		next[key_a] = b
		next[key_b] = a

	#add new key and remove the old key
	elif a != null:
		next[key_b] = a
		next.erase(key_a)
	elif b != null:
		next[key_a] = b
		next.erase(key_b)


func replace_next_event(old: String, new: String) -> void:
	for key in next:
		for i in next[key].size():
			if next[key][i] == old:
				next[key][i] = new


func add_to_next_entry(index: int, value: String, next_index := -1) -> void:
	if next_index > 0:
		value += ":%d" % next_index

	var array = next.values()[index]# doing this in one step somehow did not work
	array.append(value)
	next[next.keys()[index]] = array


func remove_from_next_entry(index: int, value: String, next_index := -1) -> void:
	if next_index > 0:
		value += ":%d" % next_index

	next[next.keys()[index]].remove(next.values()[index].find(value))

"""
	how to handle slots
		have an dict
			key
				linenumber as key
			value
				we need next to be an array of event names
					corresponds to the connections
				inputs?
					only flow at start?
						can we add more later?
							if we build the node from code it should work easily
					conditions?
						similar to next but as input and different type
					entry point at line
						add line to a dict?
							sting as value as placeholder/var name in editor only
						the list would be only needed for the editor to add it as a slot
"""
