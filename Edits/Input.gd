tool
extends EventEdit


onready var variable := $GridContainer/Variable
onready var default := $GridContainer/Default
onready var type := $GridContainer/Type
onready var chars := $GridContainer/Chars



func _ready() -> void:
	var data = get_data()
	variable.text = data.get("variable", "")
	default.text = data.get("default", "")
	type.select(data.get("var_type", 0))
	chars.value = data.get("chars", -1)
	if timeline:
		variable.completion_list = timeline.variables.keys()


static func get_regex() -> String:
	return 'input\\(\\s*(?:(?<variable>[\\w\\d]*)(?:\\s*,\\s*"(?<default>(?:[^"]|\\\\")*)"(?:\\s*,\\s*(?<type>[\\w\\d]*)(?:\\s*,\\s*(?<chars>\\d+))?)?)?)?\\s*\\)'


static func get_type() -> String:
	return "Input"


func parse(re_match: RegExMatch) -> void:
	variable.text = re_match.get_string("variable")
	default.text = re_match.get_string("default").c_unescape()
	type.select(type.get_item_index(int(re_match.get_string("type"))))
	chars.value = int(re_match.get_string("chars"))


func _on_Variable_text_changed(new_text: String) -> void:
	get_data().variable = new_text


func _on_Default_text_changed(new_text: String) -> void:
	get_data().default = new_text


func _on_OptionButton_item_selected(index: int) -> void:
	get_data().var_type = index


func _on_Chars_value_changed(value: float) -> void:
	get_data().chars = value


func get_code() -> String:
	return 'input(%s, "%s", %d, %d)' % [variable.text, default.text, type.get_selected_id(), chars.value]
