extends EventEdit

onready var show := $VBoxContainer/Show
onready var actor := $VBoxContainer/Actor
onready var animation := $VBoxContainer/Control/Animation
onready var position := $VBoxContainer/Control2/Position
onready var transforms := $VBoxContainer/Transform
onready var show_at_mode := $VBoxContainer/Control3/ShowAtMode
onready var show_at_line := $VBoxContainer/Control3/target
onready var show_at_index := $VBoxContainer/Control3/target2
onready var use_animation := $VBoxContainer/Control/use_animation
onready var use_position := $VBoxContainer/Control2/use_pos
onready var use_layer := $VBoxContainer/Control3/use_layer
onready var use_3d := $VBoxContainer/Control4/use_3d
onready var use_transform := $VBoxContainer/Control4/use_transform
onready var origin_x := $VBoxContainer/Transform/OX
onready var origin_y := $VBoxContainer/Transform/OY
onready var origin_z := $VBoxContainer/Transform/OZ
onready var basis_x_x := $VBoxContainer/Transform/XX
onready var basis_x_y := $VBoxContainer/Transform/XY
onready var basis_x_z := $VBoxContainer/Transform/XZ
onready var basis_y_x := $VBoxContainer/Transform/YX
onready var basis_y_y := $VBoxContainer/Transform/YY
onready var basis_y_z := $VBoxContainer/Transform/YZ
onready var basis_z_x := $VBoxContainer/Transform/ZX
onready var basis_z_y := $VBoxContainer/Transform/ZY
onready var basis_z_z := $VBoxContainer/Transform/ZZ


func _ready() -> void:
	for i in timeline.actors:
		actor.add_item(i)

func try_parse(default := 0) -> bool:
	return false


func _on_TransformCheckBox_toggled(button_pressed: bool) -> void:
	transforms.visible = button_pressed


func _on_ShowAtMode_item_selected(index: int) -> void:
	match index:
		0, 1:
			show_at_line.visible = true
			show_at_index.visible = false
		2:
			show_at_line.visible = false
			show_at_index.visible = true


func _on_3D_toggled(button_pressed: bool) -> void:
	origin_z.editable = button_pressed
	basis_x_z.editable = button_pressed
	basis_y_z.editable = button_pressed
	basis_z_x.editable = button_pressed
	basis_z_y.editable = button_pressed
	basis_z_z.editable = button_pressed


func save() -> void:
	var line := ""
	var actor_id: String = timeline.actors.keys()[actor.selected]

	match show.selected:
		1:#hide
			line += 'hide("%s");' % [actor_id.c_escape()]
		2:#show
			line += 'show("%s");' % [actor_id.c_escape()]

	if use_animation.pressed:
		line += 'play("%s", "%s");' % [actor_id.c_escape(), timeline.actors[actor_id].sprite.get_animation_list()[animation.selected].c_escape()]

	if use_position.pressed:
		line += 'position("%s", "%s");' % [actor_id.c_escape(), position.text.c_escape()]

	if use_layer.pressed:
		match show_at_mode.selected:
			0:#Front
				line += 'front("%s", "%s");' % [actor_id.c_escape(), show_at_line.text.c_escape()]
			1:#behind
				line += 'behind("%s", "%s");' % [actor_id.c_escape(), show_at_line.text.c_escape()]
			2:#layer
				line += 'layer("%s", "%d");' % [actor_id.c_escape(), show_at_index.value]

	if use_transform.pressed:
		if use_3d.pressed:
			line += 'transform("%s", Transform(Vector3(%r, %r, %r), Vector3(%r, %r, %r), Vector3(%r, %r, %r), Vector3(%r, %r, %r)));' % [
					actor_id.c_escape(),
					basis_x_x.value, basis_x_y.value, basis_x_z.value,
					basis_y_x.value, basis_y_y.value, basis_y_z.value,
					basis_z_x.value, basis_z_y.value, basis_z_z.value,
					origin_x.value, origin_y.value, origin_z.value
				]
		else:
			line += 'transform2("%s", Transfrom2D(Vector2(%r, %r), Vector2(%r, %r), Vector2(%r, %r)' % [
					actor_id.c_escape(),
					basis_x_x.value, basis_x_y.value,
					basis_y_x.value, basis_y_y.value,
					origin_x.value, origin_y.value
				]
	set_line(line)
	# can we make a get_sprite class and then call the functions on it?
	# -make the func return them self to call them in line
	#   -will not work for build ins
	#  howto get the data from timeline that is needed
	#   -positions
	#   -actor
	#   -sprite
	#   use a node for it?
	#    we would need 2 because 3D
	#    instace them at sprite load/extend animated sprite
	#    if the functionality is already in animated sprite can we just use it?
	#  we cant cause of the undo
	#	use the custom methods the other way works just not with the undo


func _on_Actor_item_selected(index: int) -> void:
	animation.clear()
	var sprite = timeline.actors.values()[index].sprite
	if sprite:
		for i in sprite.get_animation_names():
			animation.add_item(i)
