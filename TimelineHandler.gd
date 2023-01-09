extends BaseHandler

class_name Handler

signal choice_end(index)


export var button_theme: Theme
export var cps := 5.0
export var auto := false
export(float, 0.5, 2.0) var auto_wait_factor := 1.0


var choice_timer := Timer.new()


func _ready() -> void:
	add_child(choice_timer)
	var err = choice_timer.connect("timeout", self, "_on_choice_timeout")
	assert(err == OK)
	err = connect("choice_end", self, "_on_choice_end")
	assert(err == OK)


"""
this Class contains the functions that are called via the expressions
it is recommended to use a yield so the handler event waits.
"""

func wait(time := 1.0) -> void:
	yield(get_tree().create_timer(time), "timeout")


func text(string, flush:= true) -> void:
	if !active_text:
		return

	var old_text := active_text.bbcode_text
	if flush:
		active_text.bbcode_text = ""
	active_text.visible_characters = active_text.text.length()
	active_text.bbcode_text += string
	var new_text = active_text.bbcode_text

	undo.create_action("Text")
	undo.add_do_method(self, "_clear_boxes")
	undo.add_do_property(active_text, "bbcode_text", new_text)
	undo.add_undo_property(active_text, "bbcode_text", old_text)
	undo.commit_action()

	var speed = (active_text.text.length() - active_text.visible_characters) / cps
	var tween = get_tree().create_tween()
	print(speed)
	tween.tween_property(active_text, "visible_characters", active_text.text.length() + 1, speed)
	yield_queue.append(tween)
	yield(tween, "finished")
	yield_queue.erase(tween)
	if auto:
		var wait =get_tree().create_timer(speed * auto_wait_factor)
		yield_queue.append(wait)
		yield(wait, "finished")
		yield_queue.erase(wait)
		next()


func choice(choices:Array, time := 0.0) -> void:
	if !active_choice_box:
		return

	undo.create_action("Choice")
	undo.add_do_method(self, "_clear_boxes")
	for i in choices.size():
		var button = _create_choice_button(choices[i], i)
		undo.add_do_reference(button)
		undo.add_do_method(active_choice_box, "add_child", button)
		undo.add_undo_method(active_choice_box, "remove_child", button)
	undo.commit_action()

	if time > 0.0:
		choice_timer.start(time)
	yield(self, "choice_end")
	choice_timer.stop()
	_clear_box(active_choice_box)


func input(variable := "", default:= "", type := TYPE_STRING, max_chars := -1) -> void:
	if !active_input_box:
		return

	var line_edit = LineEdit.new()
	if max_chars >= 0:
		line_edit.max_length = max_chars
	line_edit.placeholder_text = default
	line_edit.connect("text_entered", self, "_on_input_text_entered", [variable, default, type])

	undo.create_action("Input")
	undo.add_do_method(self, "_clear_boxes")
	undo.add_do_reference(line_edit)
	undo.add_do_method(line_edit, "add_child", line_edit)
	undo.add_undo_method(line_edit, "remove_child", line_edit)
	undo.commit_action()

	yield(line_edit, "text_entered")
	_clear_box(active_input_box)


# private functions ------------------------------------------------

func _clear_boxes() -> void:
	if active_choice_box:
		for i in active_choice_box.get_children():
			active_choice_box.remove_child(i)
	if active_input_box:
		for i in active_input_box.get_children():
			active_input_box.remove_child(i)


func _on_input_text_entered(text: String, variable: String, default: String, type: int) -> void:
	if !text:
		text = default
	if variable:
		timeline.variables[variable] = convert(text, type)


func _create_choice_button(text:String, index: int) -> Button:
	var button = Button.new()
	button.text = text
	if button_theme:
		button.theme = button_theme
	button.connect("pressed", self, "_on_button_pressed", [index])
	return button


func _on_button_pressed(index) -> void:
	emit_signal("choice_end", index)


func _on_choice_timeout() -> void:
	emit_signal("choice_end", -1)


func _on_choice_end(index) -> void:
	queue_event(active_event.get_next("choice%d"%[index]))
