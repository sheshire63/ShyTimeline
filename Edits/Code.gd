tool
extends EventEdit

onready var text := $TextEdit

func _ready() -> void:
	text.text = get_line()


func _on_TextEdit_text_changed() -> void:
	_update_size()



# override ----------------------------------------------------------------

static func get_type() -> String:
	return "Code"


func get_code() -> String:
	return text.text


func parse(re_match: RegExMatch) -> void:
	text.text = re_match.strings[0]


# private ----------------------------------------------------------------


func _update_size() -> void:
	var size = text.margin_top - text.margin_bottom
	size += max(text.get_line_count() * text.get_line_height(), 64)
	rect_size.y = size
	rect_min_size.y = size
