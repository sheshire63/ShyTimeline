tool
extends ShyTimelineNode


class TextData:
	extends NodeData


	func load_data(data := {}) -> void:
		.load_data(data)


	func save_data() -> Dictionary:
		var data = .save_data()
		return data


onready var c_text = $TextEdit

#var line_slots := {}
var regex_actor := RegEx.new()


func _init():
	data = TextData.new()


func _ready() -> void:
	regex_actor.compile("^(?<actor>\\w*)@")
	c_text.add_keyword_color("hello", c_text.get_color("font_color", ""))
	load_actors()
	load_variables()
	#if !owner or (Engine.editor_hint and owner.get_parent() is Viewport):

func _set_timeline(new) -> void:
	._set_timeline(new)
	load_actors()
	load_variables()


func load_actors() -> void:
	if c_text:
		c_text.first_word_completion_list = timeline.actors.keys()
		c_text.first_word_suffix = "@ "


func load_variables() -> void:
	if c_text:
		c_text.completion_list = timeline.variables.keys()


func get_event() -> Dictionary:
	var event := .get_event()
	var re_match = regex_actor.search(c_text.text)
	var text = c_text.text
	if re_match:
		event.actor = [lex(re_match.get_string("actor"))]#todo allow string seperated list
		text = text.right(re_match.get_end())
	event.text = [lex(text)]
	return event


func _save_data() -> Dictionary:
	var save = ._save_data()
	save.text = c_text.text
	return save


func _load_data(data:= {}) -> void:
	._load_data(data)
	c_text.set_text(data.get("text", c_text.text))


func _delete() -> void:
	pass


func _copy(copy) -> void:#if you need to set somthing in the copy.
	pass


func _on_TextEdit_request_completion() -> void:
	print("TextEdit_request_completion")


func _on_TextEdit_symbol_lookup(symbol:String, row:int, column:int) -> void:
	printt("TextEdit_symbol_lookup", symbol, row, column)


func _on_TextEdit_text_updated(old:String, new:String) -> void:
	undo.emit_signal("version_changed")
