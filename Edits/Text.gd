tool
extends EventEdit

onready var text := $TextEdit


func _ready() -> void:
	text.text = get_data().get("text", "")

	if timeline:
		text.completion_list = timeline.actors.keys()


# override ----------------------------------------------------------------

static func get_regex() -> String:
	return '(?:set_actor\\(["\'](?<actor>.*)["\']\\);)?text\\((?:["\'](?<text>(?:[^\'"]|\\\\\\.)*)["\'])?\\)'


static func get_type() -> String:
	return "Text"


func parse(re_match: RegExMatch) -> void:
	var text = ""
	text += re_match.get_string("actor")
	if text:
		text += "@"

	if re_match:
		text += re_match.get_string("text")

	text.text = text


func get_code() -> String:
	var re := RegEx.new()
	var err = re.compile("^(?:(?<actors>\\w+\\s*(?:,\\s*\\g'actors')*)@)?(?<text>.+)?")
	assert(err == OK)
	var re_match = re.search(text.text)
	var line := ""
	if re_match:
		line = "text(\"%s\")" % re_match.get_string("text").c_escape()
		if re_match.get_string("actors"):
			line = 'set_actor("%s");' % re_match.get_string("actors").c_escape() + line
	else:
		line = text.text.c_escape()
	return line


# private ----------------------------------------------------------------

func _on_TextEdit_text_changed() -> void:
	get_data().text = text.text
	_update_size()
	event.emit_changed()


func _update_size() -> void:
	var size = text.margin_top + abs(text.margin_bottom)
	size += max((text.get_line_count() + 1) * text.get_line_height(), 64)
	rect_size.y = size
	rect_min_size.y = size
