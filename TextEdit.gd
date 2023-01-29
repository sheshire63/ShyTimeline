tool
extends TextEdit
class_name TextEditT
# changes that a tab key is used to switch focus instead of entering the letter
# adds a autocomplete functionality if completion_list is not empty

export var completion_list: PoolStringArray = []
export var suffix := ""#added to the completion
export var prefix := ""
export var limit_to_one := false

var is_trying_completing := false
var menu := PopupMenu.new()
var suggestions := []
var hover_index := 0


func _ready() -> void:
	connect("text_changed", self, "_on_text_changed")
	connect("focus_exited", self, "_on_focus_exited")
	add_child(menu)
	menu.connect("index_pressed", self, "add_completion")


func _input(event):
	if event is InputEventKey and has_focus() and event.is_pressed():
		match event.scancode:
			KEY_TAB, KEY_ENTER:
				if !is_trying_completing:
					continue
				add_completion()
				get_tree().set_input_as_handled()
			KEY_TAB:
				if !is_trying_completing and not Input.is_key_pressed(KEY_CONTROL):
					if Input.is_key_pressed(KEY_SHIFT):
						find_prev_valid_focus().grab_focus()
					else:
						find_next_valid_focus().grab_focus()
					get_tree().set_input_as_handled()
			KEY_UP:
				if is_trying_completing:
					hover_index -= 1
					continue
			KEY_DOWN:
				if is_trying_completing:
					hover_index += 1
					continue
			KEY_UP, KEY_DOWN:
				hover_index = wrapi(hover_index, 0, suggestions.size())
				menu.set_current_index(hover_index)


func add_completion(index := -1) -> void:
	if index < 0:
		index = hover_index
	var line = get_line(cursor_get_line())
	var pos = 0
	for i in line.split(" "):
		var end_pos = pos + i.length()
		if end_pos >= cursor_get_column():
			var add_part = suggestions[index]
			if !limit_to_one or line.find(prefix) == -1:
				add_part = prefix + add_part
			if !limit_to_one or line.find(suffix) == -1:
				add_part += suffix
			set_line(cursor_get_line(), line.left(pos) + add_part + line.right(end_pos))
			cursor_set_column(pos + add_part.length())
		pos = end_pos
	is_trying_completing = false
	menu.hide()

#todo:
	#do auto complete
		#the first word is not hovered
		#pressing tab/enter will not complete it
func _on_text_changed() -> void:
	if completion_list:
		hover_index = 0
		suggestions = []
		var word = get_word_under_cursor()
		if word == "":
			var line = get_line(cursor_get_line()).left(cursor_get_column())
			if line != "":
				word = line.right(max(0, line.rfind(" ") + 1))
		if word:
			for i in completion_list:
				if i.to_lower().begins_with(word.to_lower()):
					suggestions.append(i)

			menu.clear()
			if suggestions:
				is_trying_completing = true
				for i in suggestions:
					menu.add_item(i)

				var rect = Rect2(get_pos_at_line_column(cursor_get_line(), cursor_get_column()) + rect_global_position, menu.rect_size)
				menu.popup(rect)
				menu.set_current_index(hover_index)
				grab_focus()
				return
	is_trying_completing = false
	menu.hide()


func _on_focus_exited() -> void:
	return
	if not menu.has_focus():
		menu.hide()
