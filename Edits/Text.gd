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
	#var err = re.compile("^(?:(?<actors>\\w+\\s*(?:,\\s*\\g'actors')*?)@|(?<actors>\\t))?(?<text>.+)?") #for a list of actors
	var err = re.compile("^(?:(?<actors>\\w+\\s*)@|(?<actors>\\t))?(?<text>.+)?$")
	assert(err == OK)
	var line := ""
	var has_actor_set = true
	for i in text.get_line_count():
		var re_match = re.search(text.get_line(i) + "\n")
		if re_match:
			var text = "text(\"%s\");" % re_match.get_string("text").c_escape()
			var actor = re_match.get_string("actors")
			if actor:
				if actor != "\t":
					has_actor_set = true
					line += 'set_actor("%s");' % actor.c_escape()
			elif has_actor_set:
				has_actor_set = false
				line += 'set_actor("");'
			line += text
		else:
			print("failed to parse line: %s" % text.get_line(i).c_escape())
	line.trim_suffix(";")
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
