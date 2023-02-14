extends BaseHandler

class_name Handler

signal choice_end(index)


export var button_theme: Theme
export var cps := 5.0
export var auto := false
export(float, 0.5, 2.0) var auto_wait_factor := 1.0
export var auto_hide := false

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
i recommend to have default values for all arguments
"""

func wait(time := 1.0) -> void:
	yield(get_tree().create_timer(time), "timeout")


func text(string := "", flush:= true) -> void:
	var text = _get_text()
	if !text:
		print("no Textbox set")
		return
	text.visible = true
	var old_text: String = text.bbcode_text
	if flush:
		text.bbcode_text = ""
	text.visible_characters = text.text.length()
	text.bbcode_text += string
	var new_text = text.bbcode_text

	undo.create_action("Text")
	undo.add_do_method(self, "_clear_boxes")
	undo.add_do_property(text, "bbcode_text", new_text)
	undo.add_undo_property(text, "bbcode_text", old_text)
	undo.commit_action()

	var speed = (text.text.length() - text.visible_characters) / cps
	var tween = get_tree().create_tween()
	tween.tween_property(text, "visible_characters", text.text.length() + 1, speed)
	yield_queue.append(tween)
	yield(tween, "finished")
	yield_queue.erase(tween)
	if auto:
		var wait = get_tree().create_timer(speed * auto_wait_factor)
		yield_queue.append(wait)
		yield(wait, "finished")
		yield_queue.erase(wait)
		next()
	if auto_hide:
		text.visible = false
		var label = _get_label()
		if label:
			label.visible = false


func choice(choices := [] , time := 0.0) -> void:
	var choice = _get_choice()
	if !choice:
		print("No active choice box")
		return

	undo.create_action("Choice")
	undo.add_do_method(self, "_clear_boxes")
	for i in choices.size():
		var button = _create_choice_button(choices[i], i)
		undo.add_do_reference(button)
		undo.add_do_method(choice, "add_child", button)
		undo.add_undo_method(choice, "remove_child", button)
	undo.commit_action()

	if time > 0.0:
		choice_timer.start(time)
	yield(self, "choice_end")
	choice_timer.stop()
	_clear_box(choice)


func input(variable := "", default:= "", type := TYPE_STRING, max_chars := -1) -> void:
	var input = _get_input()
	if !input:
		print("No active input box")
		return

	var line_edit = LineEdit.new()
	if max_chars >= 0:
		line_edit.max_length = max_chars
	line_edit.placeholder_text = default
	line_edit.connect("text_entered", self, "_on_input_text_entered", [variable, default, type])

	undo.create_action("Input")
	undo.add_do_method(self, "_clear_boxes")
	undo.add_do_reference(line_edit)
	undo.add_do_method(input, "add_child", line_edit)
	undo.add_undo_method(input, "remove_child", line_edit)
	undo.commit_action()

	yield(line_edit, "text_entered")
	_clear_box(input)


# sprites --------------------------------------------------

func show(actor := "") -> void:
	var sprite = _get_sprite(actor)
	if sprite:
		undo.create_action("show")
		undo.add_do_property(sprite, "visible", true)
		undo.add_undo_property(sprite, "visible", sprite.visible)
		undo.commit_action()


func hide(actor := "") -> void:
	var sprite = _get_sprite(actor)
	if sprite:
		undo.create_action("hide")
		undo.add_do_property(sprite, "visible", false)
		undo.add_undo_property(sprite, "visible", sprite.visible)
		undo.commit_action()


# trys to find and play the animation in AnimationPlayers first
func play(target := "", animation := "", wait := false) -> void:
	if !animation:
		return
	var player = _get_player(target)# get animation player
	if !player or not player.has_animation(animation):
		player = _get_sprite(target) # get sprite if the animation player does not exist or does not have the animation

	if player and player.has_animation(animation):

		undo.create_action("play")
		undo.add_do_method(player, "play", animation)
		if player is AnimationPlayer:
			undo.add_undo_method(player, "play_backwards", animation)
		elif player is AnimatedSprite:
			undo.add_undo_method(player, "play", animation, true)
		undo.commit_action()

		if wait:
			yield(player, "animation_finished")


func behind(actor := "", target_actor := "") -> void:
	var target = _get_sprite(target_actor)
	at(actor, target.z_index - 1)



func front(actor := "", target_actor := "") -> void:
	var target = _get_sprite(target_actor)
	at(actor, target.z_index - 1)


func at(actor := "", layer := 0) -> void:
	layer = clamp(layer, -4096, 4096)
	var sprite = _get_sprite(actor)
	if sprite:
		undo.create_action("set_layer")
		undo.add_do_property(sprite, "z_index", layer)
		undo.add_undo_property(sprite, "z_index", sprite.z_index)
		undo.commit_action()


func move(actor := "", position_id := "", transform = null, transition := -1, easing := 0, time := 1.0, wait := false) -> void:
	# transition is a Tween.TransitionType
	var sprite = _get_sprite(actor)
	if !sprite:
		return
	var target_node: Node2D = _get_position(position_id)
	var from_node: Node2D = sprite.get_parent()
	var from = sprite.global_transform

	undo.create_action("move")
	undo.add_do_method(sprite.get_parent(), "remove_child", sprite)
	undo.add_undo_method(sprite.get_parent(), "add_child", sprite)
	undo.add_do_method(target_node, "add_child", sprite)
	undo.add_undo_method(target_node, "remove_child", sprite)
	if typeof(sprite.transform) == typeof(transform):
		undo.add_do_property(sprite, "transform", transform)
		undo.add_undo_property(sprite, "transform", sprite.transform)
	undo.commit_action()

	if transition >= 0:
		var result = sprite.global_transform
		sprite.global_transform = from

		var tween = create_tween()
		tween.tween_property(sprite, "global_transform", result, time)
		tween.set_trans(transition)
		tween.set_ease(easing)
		tween.play()
		if wait and tween.is_running():
			yield(tween, "finished")



# private functions ------------------------------------------------

func _clear_boxes() -> void:
	var box = _get_choice()
	if box:
		for i in box.get_children():
			box.remove_child(i)
	box = _get_input()
	if box:
		for i in box.get_children():
			box.remove_child(i)


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
	queue_event(active_event.get_next("%dchoice%d"%[current_line, index]))


