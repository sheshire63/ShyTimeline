tool
extends Node

class_name TimelineHandler


signal event_handled
signal choice_selected


export var cps = 5.0 #todo move to settings
export var wait_time := 3.0
export var auto := true
export var start := ""

export(Array, NodePath) var text_boxes := []
export(Array, NodePath) var choice_boxes := []


var text_controls := {}
var choice_controls := {}
var actor_label_boxes := {}
var choice_buttons := {}
var queue := []
var next_queue := {}
var active_yield_queue := []# queue of yield object
var variables := {}
var undo := ShyUndo.new()
var current_actor_hash := 0


var timeline := ShyTimeline.new() setget , _get_timeline; func _get_timeline():
		if !timeline:
			timeline = ShyTimeline.new()
		return timeline


func _get_property_list() -> Array:
	return [
		{
			"name": "timeline",
			"usgae": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR,
			"type": TYPE_OBJECT,
			"hint_string": "ShyTimeline",
		},
	]


func _ready() -> void:
	if Engine.editor_hint:
		return
	_load_text_boxes()
	_load_actor_label_boxes()
	_load_choice_boxes()
	_load_choice_buttons()
	if start:
		handle(start)


func _unhandled_key_input(event: InputEventKey) -> void:
	if event.pressed:
		if active_yield_queue:
			skip()
		elif queue:
			next()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("rollforward"):
		auto = false
		if active_yield_queue:
			skip()
		undo.redo()
	if event.is_action_pressed("rollbackward"):
		auto = false
		if active_yield_queue:
			skip()
		undo.undo()


func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_CONTROL):
		skip()




func skip() -> void:
	if active_yield_queue:
		var item = active_yield_queue[0]
		if item is SceneTreeTimer:
			if item.time_left > 0.0:
				item.emit_signal("timeout")
		else:
			item.set_speed_scale(10)


func next() -> void:
	undo.commit()
	if queue:
		undo.add_undo(self, "queue", queue.duplicate())
		var event = queue.pop_front()
		undo.add_do(self, "queue", queue.duplicate())
		yield(handle(event), "completed")
		undo.commit()
	else:
		end()


func end() -> void:
	print("timeline finished")


func queue(event: String, silent := false) -> void:
	if event in timeline.nodes:
		undo.add_undo(self, "queue", queue.duplicate())
		queue.append(event)
		undo.add_do(self, "queue", queue.duplicate())
	elif !silent:
		print("Event '%s' not in Timeline" % [event])


func handle(event: String) -> void:
	print(event)
	if !event in timeline.nodes:
		print("Node not found:", event)
		return

	var code = timeline.nodes[event]
	var text_boxes := []
	var actors := []
	var next := []

	if code.has("actor"):
		for i in code.actor:
			actors.append(determin_value([i], next))
	if code.has("text_box"):
		text_boxes.append(determin_value(code.text_box, next))
	if !code.overwrite_text_box:
		for i in actors:
			var actor = timeline.actors[i]
			if actor.text_box:
				text_boxes.append(actor.text_box)
	if !text_boxes:
		text_boxes = [""]

	if current_actor_hash != actors.hash() | text_boxes.hash():#todo test if this works
		set_actors(actors, text_boxes)

	if code.has("text"):
		var text = determin_value(code.text, next)
		yield(output_text(text, text_boxes), "completed")

	if code.has("next"):
		for i in code.next:
			next.append([i])
	if code.has("choices"):
		var choices = []
		for i in code.choices:
			if not i.has("condition") or determin_value(i.condition, []):
				var text = determin_value(i.value, [])
				if text:
					choices.append(text)
		choice(choices, determin_value(code.choice_box, []) if code.has("choice_box") else "")
		yield(self, "choice_selected")#todo add timeout option
	elif auto:
		var timer = get_tree().create_timer(wait_time)
		active_yield_queue.append(timer)
		yield(timer, "timeout")
		active_yield_queue.erase(timer)
		if auto:
			call_deferred("next")
	for i in next:
		queue(determin_value(i, []), true)


func choice(choices: Array, box_name := "") -> void:
	if not box_name in choice_controls:
		box_name = ""
	var box = choice_controls[box_name]
	for i in choices:
		if not "condition" in i or determin_value(i.condition, []):
			var next = []
			var button = choice_buttons.get(box_name, choice_buttons[""]).duplicate()
			_add_choice(button, box, determin_value([i], next), next)
	box.visible = true
	undo.add_do(box, "visible", true)
	undo.add_undo(box, "visible", false)
	undo.commit()


func _add_choice(button: BaseButton, box: Container, text: String, next: Array) -> void:
	button.text = text
	button.connect("pressed", self, "_on_choice_selected", [next, box])
	undo.add_do_method(box, "add_child", [button])
	undo.add_undo_method(box, "remove_child", [button])
	box.add_child(button)


func output_text(text := "", text_boxes := [""], flush := true) -> void:
	var labels = []
	var tween = get_tree().create_tween()
	for i in text_boxes:
		var label = text_controls[i]
		labels.append(label)
		undo.add_undo(label, "text", label.bbcode_text)
		undo.add_undo(label, "visible_characters", label.text.length())
		if flush:
			label.bbcode_text = ""
		label.visible_characters = label.text.length()
		label.bbcode_text += text
		undo.add_do(label, "text", label.bbcode_text)
		undo.add_do(label, "visible_characters", label.text.length())
		tween.tween_property(label, "visible_characters", label.text.length(), (label.text.length() - label.visible_characters) / cps)
	active_yield_queue.append(tween)
	tween.tween_callback(self, "_remove_from_queue", [tween])
	yield(tween, "finished")


func set_actors(actors: Array, text_boxes := [""]) -> void:#todo change to set actor
	#todo set the theme of all relevant controls
	current_actor_hash = actors.hash() | text_boxes.hash()
	var theme:= Theme.new()
	for i in actors:
		if i in timeline.actors and timeline.actors[i].theme:
			theme.copy_theme(timeline.actors[i].theme)
	for i in text_boxes:
		var box = actor_label_boxes[i if i in actor_label_boxes else ""]
		for j in box.get_children():
			box.remove_child(j)
			j.queue_free()
		for j in actors:
			if j in timeline.actors:
				var actor = timeline.actors[j]
				var label = Label.new()
				label.text = actor.label
				if actor.theme:
					label.theme = actor.theme
				box.add_child(label)
			else:
				print("Actor '%s' not in timeline" % [j])
		if text_controls[i]:
			text_controls[i].theme = theme


func clear_button_box(box) -> void:
	box.visible = false
	for i in box.get_children():
		box.remove_child(i)
		i.queue_free()


func determin_value(data: Array, next: Array) -> String:
	var text := ""
	for i in data:
		if !i:
			continue
		var new = _determin_value(i, next)
		if new == "":
			text = text.strip_edges(false, true)
		text += new
	return text


func _determin_value(data, next:Array) -> String:
	if data is Dictionary:
		return _determin_value([data], next)
	elif data is Array:
		var total_weight = 0.0
		var weights = {} # ?todo make sure identical entrys dont cause an error(dict as key)
		var defaults = []
		for j in data:
			if j is Dictionary:
				if j.has("condition"):
					if !determin_value(j.condition, []):
						continue
				if j.has("weight"):
					weights[j] = float(determin_value(j.weight, []))
					total_weight += weights[j]
					continue
			defaults.append(j)
		var rand = randf() * max(1.0, total_weight)
		for j in weights:
			rand -= weights[j]
			if rand <= 0:
				if j.has("next") and j.next:
					next.append(j.next)
				return determin_value(j.value, next)
		if rand > 0.0 and defaults:
			var entry = defaults[rand_range(0, defaults.size())]
			if entry is Dictionary:
				if entry.has("next") and entry.next:
					next.append(entry.next)
				return determin_value(entry.value, next)
			return determin_value(entry, next)# error if entry is array?
		else:
			return ""
	else:
		var expression = Expression.new()
		var err = expression.parse(str(data), variables.keys())
		if err != OK:
			return str(data)
		var result = expression.execute(variables.values(), self, false)
		if expression.has_execute_failed():
			return str(data)
		return str(result)


func _remove_from_queue(object: Object) -> void:
	if object in active_yield_queue:
		active_yield_queue.erase(object)


func _load_text_boxes() -> void:
	for i in text_boxes:
		var box = get_node(i)
		if !text_controls:
			text_controls[""] = box# set first entry as default
		text_controls[box.name] = box
	if !text_controls:
		var default_text_control = RichTextLabel.new()
		add_child(default_text_control)

		#todo fix the rect extends outside the view
		default_text_control.set_anchors_and_margins_preset(Control.PRESET_WIDE, 0, 16)
		default_text_control.set_anchor_and_margin(MARGIN_TOP, 0.6, 0, false)
		#default_text_control.set_margin(MARGIN_RIGHT, -16.0)
		default_text_control.bbcode_enabled = true
		text_controls[""] = default_text_control


func _load_actor_label_boxes() -> void:
	for i in text_controls:
		if i in actor_label_boxes:
			continue
		#todo add option to not at labels
		var area = Control.new()
		var text_control = text_controls[i]
		var parent = text_control.get_parent()
		if parent is Container:
			area.rect_size = text_controls[i].rect_size
		else:
			for j in 4:
				area.set_anchor(j, text_control.get_anchor(j))
				area.set_margin(j, text_control.get_margin(j))

		parent.add_child_below_node(text_control, area)
		parent.remove_child(text_control)
		area.add_child(text_control)
		text_control.set_anchors_and_margins_preset(Control.PRESET_WIDE)

		var box = VBoxContainer.new()
		box.set_anchors_and_margins_preset(Control.PRESET_TOP_WIDE)
		area.add_child(box)
		actor_label_boxes[i] = box
		box.margin_top = -32
		box.margin_bottom = -32


func _load_choice_boxes() -> void:
	for i in choice_boxes:
		var box = get_node(i)
		if !choice_controls:
			choice_controls[""] = box
		choice_controls[box.name] = box
	if !choice_controls:
		var default_choice_control = VBoxContainer.new()
		default_choice_control.set_margins_preset(Control.PRESET_WIDE, 0, 128)
		add_child(default_choice_control)
		choice_controls[""] = default_choice_control


func _load_choice_buttons() -> void:
	for i in choice_controls:
		var button: Button
		var box: Container = choice_controls[i]
		if box.get_child_count():
			button = box.get_child(0)
			box.remove_child(button)
		if !button:
			button = Button.new()
			button.rect_min_size = Vector2(128, 32)
		box.visible = false
		choice_buttons[i] = button


func _on_choice_selected(next: Array, box) -> void:
	for i in next:
		queue(i)
	emit_signal("choice_selected")
	clear_button_box(box)
	next()



