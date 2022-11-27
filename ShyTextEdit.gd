tool
extends TextEdit



signal word_changed(word, line, collumn)# emited when a word is changed except last_letter
signal word_entered(word, line, collumn)# emited whenn a letter is added to a word
#signal line_added(line)
signal request_completion_property(property_layers)
signal text_updated(old, new)

export var completion_list: PoolStringArray = []
export var first_word_completion_list: PoolStringArray = []
export var first_word_suffix := ""

var get_last_word_regex := RegEx.new()
var is_one_word_regex := RegEx.new()
var sub_item_regex := RegEx.new()
var _suggestion := ""
var _suggestion_part := ""
var timer := Timer.new()
var _last_text := ""



func _ready() -> void:
	_last_text = text
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "_on_change_timeout")
	get_last_word_regex.compile("\\w+$")
	is_one_word_regex.compile("^\\w+$")
	sub_item_regex.compile("(\\w+\\.)+(\\w+$)")# todo exclude .
	connect("text_changed", self, "_on_text_changed")
	connect("cursor_changed", self, "_on_cursor_changed")


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if _suggestion and event.scancode == KEY_TAB:
			add_suggestion()
			get_tree().set_input_as_handled()


func _draw() -> void:
	if _suggestion:
		var font = get_font("font", "")
		var pos = get_pos_at_line_column(cursor_get_line(), 0)# get_pos_at_line_column does not work if the cursor is at the right end of a line
		var font_size = font.get_string_size(get_line(cursor_get_line()).left(cursor_get_column()))
		pos.x = get_total_gutter_width()
		pos += font_size
		var rect = Rect2(pos, font.get_string_size(_suggestion))
		rect.position.y += font.get_descent() - font.get_height()
		draw_rect(rect, get_color("completion_background_color", ""))
		draw_string(font, pos, _suggestion, get_color("completion_font_color", ""))


func _on_text_changed() -> void:
	timer.start(3)
	_suggestion = ""
	_suggestion_part = ""
	var word = get_word_under_cursor()
	if word:
		emit_signal("word_changed", word, cursor_get_line(), cursor_get_column())
		return

	var line := get_line(cursor_get_line()).left(cursor_get_column())
	var regex_result = sub_item_regex.search(line)
	if regex_result:
		emit_signal("request_completion_property", regex_result.strings.slice(1, -1))
		return
	regex_result = get_last_word_regex.search(line)
	if regex_result:
		if first_word_completion_list and is_one_word_regex.search(line):
			#emit_signal("first_word_entered", regex_result.strings[0], cursor_get_line(), cursor_get_column())
			try_completing(regex_result.strings[0], first_word_completion_list, first_word_suffix)
		else:
			try_completing(regex_result.strings[0], completion_list)
		emit_signal("word_entered", regex_result.strings[0], cursor_get_line(), cursor_get_column())
	update()


func _on_cursor_changed() -> void:
	pass#_suggestion = ""


func _on_change_timeout() -> void:
	emit_signal("text_updated", _last_text, text)
	_last_text = text


func set_text(new := "") -> void:
	_last_text = new
	text = new


func try_completing(segment: String, list: PoolStringArray, suffix := "") -> void:
	for i in list:
		if i.to_lower().begins_with(segment.to_lower()):
			_suggestion = i + suffix
			_suggestion_part = i.right(segment.length())
			update()
			return


func add_suggestion() -> void:
	var line = get_line(cursor_get_line())
	var pos = line.length() - cursor_get_column()
	line = is_one_word_regex.sub(_suggestion, "")
	set_line(cursor_get_line(), line)
	cursor_set_column(line.length() - pos)


# todo:
	#add functionalty to show multiple _suggestions

# bugs:
	#completion shows after undo
		#might be fixed through update in text_changed