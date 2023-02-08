tool
extends Resource
class_name Event

# use emit_changed() to update graphNode and editView

export var lines: PoolStringArray = [] as PoolStringArray
export var next: Dictionary #"next", "choice[-1,..,x]", x(int for linenumber) value as poolstring array

export var editor_position := Vector2.ZERO setget _set_editor_position; func _set_editor_position(new) -> void:
	editor_position = new
	emit_changed()
export var editor_data: Array



func _init() -> void:
	if next == null:
		 next = {"next": [] as PoolStringArray}
	if editor_data == null:
		editor_data = []


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


func remove_line(line : int) -> void:
	editor_data.remove(line)
	if lines.size() > line:
		lines.remove(line)

	var to_remove := []
	for key in next:
		if (key is int and key == line) or (key is String and key.begins_with(str(line))):
			to_remove.append(key)
	for key in to_remove:
		next.erase(key)
	emit_changed()


func set_line(text : String, id: int) -> void:
	while lines.size() < id:
		lines.append("")
	lines[id] = text
	emit_changed()


func set_lines(_lines: PoolStringArray) -> void:
	lines = _lines
	emit_changed()


func add_next_entry(key) -> void:
	if not next.has(key):
		next[key] = [] as PoolStringArray
		emit_changed()


func remove_next_entry(key) -> void:
	if next.has(key):
		next.erase(key)
		emit_changed()


func has_slot_entry(key) -> bool:
	return key in next


func switch_lines(a: int, b: int) -> void:#todo same for controls
	_switch_entries_in_dict(a, b, next)

	assert(lines.size() > a and lines.size() > b)
	var a_value = lines[a]
	lines[a] = lines[b]
	lines[b] = a_value

	var next_entries := []
	var re = RegEx.new()
	var err = re.compile("^(?<number>\\d*)(?<line>[\\w\\W]*)")
	assert(err == OK)
	for i in next:
		if i is String:
			var re_match = re.search(i)
			if re_match:
				var digit = re_match.get_string("number")
				if digit and int(digit) == a:
					next_entries.append([i, str(b) + re_match.get_string("line")])
	for i in next_entries:
		_switch_entries_in_dict(i[0], i[1], next)

	call_deferred("emit_changed")


func switch_next_entry(key_a, key_b) -> void:
	_switch_entries_in_dict(key_a, key_b, next)
	call_deferred("emit_changed")


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
	sort_next_entrys()



func remove_from_next_entry(index: int, value: String, next_index := -1) -> void:
	if next_index > 0:
		value += ":%d" % next_index

	next[next.keys()[index]].remove(next.values()[index].find(value))


func sort_next_entrys() -> void:
	var keys = next.keys()
	keys.sort()
	var new = {}
	for key in next.keys():
		new[key] = next[key]
	next = new



func _switch_entries_in_dict(key_a, key_b, dictionary: Dictionary) -> void:
	var entry_a = dictionary.get(key_a)
	var entry_b = dictionary.get(key_b)

	if entry_a:
		dictionary[key_b] = entry_a
	else:
		dictionary.erase(key_b)

	if entry_b:
		dictionary[key_a] = entry_b
	else:
		dictionary.erase(key_a)
