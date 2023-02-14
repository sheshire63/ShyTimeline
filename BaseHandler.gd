extends Node
class_name BaseHandler


export(Array, NodePath) var text_boxes_paths := []
export(Array, NodePath) var labels_paths := []
export(Array, NodePath) var choice_boxes_paths := []
export(Array, NodePath) var input_boxes_paths := []
export(Array, NodePath) var animation_players_paths := []
export(NodePath) var sprite_positions_path := ""
export var load_sprites_at_ready := true
export var use_3d_sprites := false
export var default_z_index := 0
export var hide_controls := false

export(Resource) var timeline = Timeline.new()
export var start := "start"


var text_boxes := {}
var labels := {}
var choice_boxes := {}
var input_boxes := {}
var animation_players := {}
var sprite_positions := {}
var sprites := {}



var undo := UndoRedo.new()
var queue := []
var active_event: Event
var current_line := 0


var active_actor: Actor
var active_control := ""
var yield_queue := []
var theme = Theme.new()



func _ready() -> void:
	theme.copy_default_theme()
	text_boxes = _load_nodes_into_dict(text_boxes_paths, RichTextLabel)
	labels = _load_nodes_into_dict(labels_paths, Label)
	choice_boxes = _load_nodes_into_dict(choice_boxes_paths, Container)
	input_boxes = _load_nodes_into_dict(input_boxes_paths, Container)
	animation_players = _load_nodes_into_dict(animation_players_paths, AnimationPlayer)
	_load_sprite_positions()
	if load_sprites_at_ready:
		_load_sprites()
	if !Engine.editor_hint:
		queue_event(start)
		next()


#func _process(_delta: float) -> void:
#	if !active_event:
#		next()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and !event.pressed:
		skip()


func next() -> void:
	if queue:
		handle(queue.pop_front())


func handle(event: Event) -> void:
	assert(event)
	active_event = event
	for line in event.get_line_size():
		current_line = line
		var expression = ShyExpression.new()
		expression.handle(event.lines[line], timeline.variables, self)
		if expression.is_running:
			yield(expression, "completed")

	for i in event.get_next("next"):
		queue_event(i)
	active_event = null
	current_line = -1


func queue_event(event_id: String) -> void:
	if !event_id:
		return
	var event: Event = timeline.get_event(event_id)
	if event:
		queue.append(event)
	else:
		print("Event %s not found" % event_id)


func skip() -> void:
	if yield_queue:
		var yield_object = yield_queue[0]
		if yield_object is SceneTreeTimer:
			yield_object.time_left = 0.0
		elif SceneTreeTween:
			yield_object.set_speed_scale(10.0)
	else:
		next()



# functions for expressions ----------------------------------------------------------------

func set_actor(actor_id := "") -> void:
	var actor = _get_actor(actor_id)
	undo.create_action("set_actor")
	undo.add_do_method(self, "_set_actor", actor)
	undo.add_undo_method(self, "_set_actor", active_actor)
	undo.commit_action()


func set_control(control := "") -> void:
	undo.create_action("set_control")

	undo.add_do_method(self, "_set_control", control)
	undo.add_undo_method(self, "_set_control", active_control)

	undo.commit_action()



# private ----------------------------------------------------------------

func _clear_box(box: Container) -> void:
	for child in box.get_children():
		box.remove_child(child)
		child.queue_free()


func _load_nodes_into_dict(paths: Array, type = null) -> Dictionary:
	var dict := {}
	for i in paths:
		if i:
			var new = get_node(i)
			if new:
				if !dict:
					dict[""] = new
				elif hide_controls:
					new.visible = false
				if (type and new is type) or !type:
					dict[new.name] = new
				else:
					printerr("%s is the wrong Type" % new)
			else:
				printerr("Node %s not found" % i)
		else:
			printerr("No NodePath specified")
	return dict


func _set_control(id := "") -> void:
	if hide_controls:
		_get_text().visible = false
		_get_label().visible = false
		_get_choice().visible = false
		_get_input().visible = false

	active_control = id

	var text = _get_text()
	if text:
		text.visible = true
		text.theme = theme

	var label =_get_label()
	if label:
		label.visible = true
		label.theme = theme
		label.text = active_actor.name if active_actor else ""

	var choice = _get_choice()
	if choice:
		choice.visible = true
		choice.theme = theme

	var input =_get_input()
	if input:
		input.visible = true
		input.theme = theme


func _load_sprite_positions() -> void:
	if sprite_positions_path:
		var node = get_node(sprite_positions_path)
		if !node:
			return
		for i in node.get_children():
			sprite_positions[i.name] = i
	var empty = Spatial.new() if use_3d_sprites else Node2D.new()
	add_child(empty)
	empty.global_position = Vector3.ZERO if use_3d_sprites else Vector2.ZERO
	sprite_positions[""] = empty


func _load_sprites() -> void:
	for i in timeline.actors:
		var sprite = _get_sprite(i)
		if sprite:
			sprite.visible = false


func _get_player(id := "") -> AnimationPlayer:
	return animation_players.get(id)

# returns sprite of the given actor if the actor exists and has a sprite
# if id is empty returns the first found visible sprite
func _get_sprite(id := ""):
	if id in sprites:
		return sprites[id]
	var actor = _get_actor(id)
	if id and actor and actor.sprite:
		var sprite = AnimatedSprite3D if use_3d_sprites else AnimatedSprite.new()
		if sprite is AnimatedSprite:
			sprite.z_as_relative = false
			sprite.z_index = default_z_index
		sprite.frames = actor.sprite
		sprites[id] = sprite
		sprite_positions[""].add_child(sprite)
		return sprite
	if id == "":
		for i in sprites:
			if i.visible:
				return i
	return null


func _get_actor(id:String) -> Actor:
	return timeline.actors.get(id)


func _set_actor(actor: Actor) -> void:
	active_actor = actor
	if actor and actor.theme:
		theme.merge_with(actor.theme)
	var label = _get_label()
	label.text = actor.name if actor else ""
	label.visible = true


func _get_position(id := "") -> Node:
	if id in sprite_positions:
		return sprite_positions[id]
	else:
		return sprite_positions[""]


func _get_label(id := "") -> Label:
	if id:
		return labels.get(id)
	else:
		return labels.get(active_control)



func _get_text(id := "") -> RichTextLabel:
	if id:
		return text_boxes.get(id)
	else:
		return text_boxes.get(active_control)



func _get_choice(id := "") -> Container:
	if id:
		return choice_boxes.get(id)
	else:
		return choice_boxes.get(active_control)


func _get_input(id := "") -> Container:
	if id:
		return input_boxes.get(id)
	else:
		return input_boxes.get(active_control)
