tool
extends EventEdit

onready var text := $TextEdit
var changed := false

func _ready() -> void:
	if get_line_number() in event.actors:
		text.text += event.actors[get_line_number()] + ", "
	if text.text:
		text.text += "@"

	if re_match:
		text.text += re_match.get_string("text")

	if timeline:
		text.completion_list = timeline.actors.keys()

# static/override ----------------------------------------------------------------

static func get_regex() -> String:
	return 'text\\((?:["\'](?<text>(?:[^\'"]|\\\\\\.)*)["\'])?\\)'


static func get_type() -> String:
	return "Text"


# private ----------------------------------------------------------------

func _on_TextEdit_text_changed() -> void:
	changed = true
	_update_size()


func _on_TextEdit_focus_exited() -> void:
	if changed:
		var re := RegEx.new()
		var err = re.compile("^(?:(?<actors>(?:\\w+\\s*,\\s*)*)@)?(?<text>.+)?")
		assert(err == OK)
		var re_match = re.search(text.text)
		var line := ""
		if re_match:
			line = "text(\"%s\")" % re_match.get_string("text").c_escape()
			event.actors[get_line_number()] = re_match.get_string("actors").replace(" ", "").split(",")
		else:
			print("failed to extract actors")
			line = text.text.c_escape()
		set_line(line)
		changed = false


func _update_size() -> void:
	var size = text.margin_top + abs(text.margin_bottom)
	size += max((text.get_line_count() + 1)  * text.get_line_height(), 64)
	rect_size.y = size
	rect_min_size.y = size
