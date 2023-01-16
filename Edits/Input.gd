tool
extends EventEdit

onready var variable := $GridContainer/Variable
onready var default := $GridContainer/Default
onready var type := $GridContainer/Type
onready var chars := $GridContainer/Chars



func _ready() -> void:
	assert(re_match)
	variable.text = re_match.get_string("variable")
	default.text = re_match.get_string("default").c_unescape()
	type.select(type.get_item_index(int(re_match.get_string("type"))))
	chars.value = int(re_match.get_string("chars"))


static func get_regex() -> String:
	return 'input\\(\\s*(?:(?<variable>[\\w\\d]*)(?:\\s*,\\s*"(?<default>(?:[^"]|\\\\")*)"(?:\\s*,\\s*(?<type>[\\w\\d]*)(?:\\s*,\\s*(?<chars>\\d+))?)?)?)?\\s*\\)'


static func get_type() -> String:
	return "Input"


func _on_Variable_text_changed(new_text: String) -> void:
	_update_line()


func _on_Default_text_changed(new_text: String) -> void:
	_update_line()


func _on_OptionButton_item_selected(index: int) -> void:
	_update_line()


func _on_Chars_value_changed(value: float) -> void:
	_update_line()


func _update_line() -> void:
	set_line('input(%s, "%s", %d, %d)' % [variable.text, default.text, type.get_selected_id(), chars.value])
