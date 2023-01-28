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


var active_actor: Actor setget _set_active_actor; func _set_active_actor(actor: Actor) -> void:
	active_actor = actor
	_update_theme(actor.theme)
var active_control: String setget _set_active_control; func _set_active_control(control: String) -> void:
	active_control = control
	_update_active_label(control)
	_update_active_text(control)
	_update_boxes(control)
	_update_theme(active_actor.theme)
var active_label: Label
var active_text: RichTextLabel
var active_choice_box: Container
var active_input_box: Container
var yield_queue := []



func _ready() -> void:
	text_boxes = _load_nodes_into_dict(text_boxes_paths, RichTextLabel)
	labels = _load_nodes_into_dict(labels_paths, Label)
	choice_boxes = _load_nodes_into_dict(choice_boxes_paths, Container)
	input_boxes = _load_nodes_into_dict(input_boxes_paths, Container)
	animation_players = _load_nodes_into_dict(animation_players_paths, AnimationPlayer)
	_load_sprite_positions()
	if load_sprites_at_ready:
		_load_sprites()
	if text_boxes:
		active_text = text_boxes.values()[0]
	if choice_boxes:
		active_choice_box = choice_boxes.values()[0]
	if input_boxes:
		active_input_box = input_boxes.values()[0]
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
		if line in event.controls:
			self.active_control = event.controls[line]
		if line in event.actors:
			self.active_actor = event.actors[line]
		var expression = ShyExpression.new()
		expression.handle(event.lines[line], timeline.variables, self)
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
				if (type and new is type) or !type:
					dict[new.name] = new
				else:
					printerr("%s is the wrong Type" % new)
			else:
				printerr("Node %s not found" % i)
		else:
			printerr("No NodePath specified")
	return dict


func _update_theme(theme: Theme) -> void:
	active_label.theme = theme
	active_choice_box.theme = theme
	active_input_box.theme = theme


func _update_active_label(label: String) -> void:
	active_label.visible = false
	if label in labels:
		active_label = labels[label]
		active_label.text = active_actor.name
		active_label.visible = true


func _update_active_text(name: String) -> void:
	active_text.visible = false
	if name in text_boxes:
		active_text = text_boxes[name]
		active_text.bbcode_text = ""
		active_text.visible = true


func _update_boxes(name: String) -> void:
	active_choice_box.visible = false
	active_input_box.visible = false
	_clear_box(active_choice_box)
	_clear_box(active_input_box)
	if name in choice_boxes:
		active_choice_box = choice_boxes[name]
	if name in input_boxes:
		active_input_box = input_boxes[name]


func _load_sprite_positions() -> void:
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
		_get_sprite(i).visible = false


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


func _get_position(id := "") -> Node:
	if id in sprite_positions:
		return sprite_positions[id]
	else:
		return sprite_positions[""]
