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
	var err = re.compile("^(?:(?<actors>\\w+\\s*(?:,\\s*\\g'actors')*)@|(?<actors>\\t))?(?<text>.+)?")
	assert(err == OK)
	var line := ""
	for i in text.get_line_count():
		var re_match = re.search(text.get_line(i) + "\n")
		if re_match:
			var text = "text(\"%s\")" % re_match.get_string("text").c_escape()
			var actor = re_match.get_string("actors")
			if actor:
				if actor != "\t":
					line += 'set_actor("%s");' % actor.c_escape()
			else:
				line += 'set_actor("");' % actor.c_escape()
			line += text

		else:
			line = text.get_line(i).c_escape()
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
