extends EventEdit

onready var show := $VBoxContainer/Show
onready var actor := $VBoxContainer/Actor

onready var use_animation := $VBoxContainer/Animation/Use
onready var animation := $VBoxContainer/Animation/ID
onready var animation_wait := $VBoxContainer/Animation/Wait

onready var use_layer := $VBoxContainer/Layer/Use
onready var layer_mode := $VBoxContainer/Layer/Mode
onready var layer_line := $VBoxContainer/Layer/ID
onready var layer_index := $VBoxContainer/Layer/Index

onready var use_move := $VBoxContainer/Move/Use
onready var move_id := $VBoxContainer/Move/ID
onready var use_transition := $VBoxContainer/Transform/Transition
onready var transition := $VBoxContainer/Transition
onready var transition_type := $VBoxContainer/Transition/Type
onready var transition_ease := $VBoxContainer/Transition/Ease
onready var transition_time := $VBoxContainer/Transition/Time
onready var transition_wait := $VBoxContainer/Transition/Wait

onready var use_transform := $VBoxContainer/Transform/Use
onready var transform_use_3d := $VBoxContainer/Transform/Use3D
onready var transforms := $VBoxContainer/Transform

onready var transform_data := $VBoxContainer/TransformData
onready var origin_x := $VBoxContainer/TransformData/OX
onready var origin_y := $VBoxContainer/TransformData/OY
onready var origin_z := $VBoxContainer/TransformData/OZ
onready var basis_x_x := $VBoxContainer/TransformData/XX
onready var basis_x_y := $VBoxContainer/TransformData/XY
onready var basis_x_z := $VBoxContainer/TransformData/XZ
onready var basis_y_x := $VBoxContainer/TransformData/YX
onready var basis_y_y := $VBoxContainer/TransformData/YY
onready var basis_y_z := $VBoxContainer/TransformData/YZ
onready var basis_z_x := $VBoxContainer/TransformData/ZX
onready var basis_z_y := $VBoxContainer/TransformData/ZY
onready var basis_z_z := $VBoxContainer/TransformData/ZZ

#todo clean this up
# move the transform controls in an array/dict to reduce copied code


func _ready() -> void:
	for i in ClassDB.class_get_enum_constants("Tween", "EaseType"):
		transition_ease.add_item(i)
	for i in ClassDB.class_get_enum_constants("Tween", "TransitionType"):
		transition_type.add_item(i)
	for i in timeline.actors:
		actor.add_item(i)
	_load_data()


func _load_data() -> void:
	var data := get_data()

	show.select(data.get("show", 0))
	actor.select(timeline.actors.keys().find(data.get("actor", "")))

	use_animation.pressed = data.get("use_animation", false)
	var sprite = _get_sprite()
	if sprite:
		animation.select(sprite.get_animation_list().find(data.get("animation", "")))
	animation_wait.pressed = data.get("animation_wait", false)

	use_layer.pressed = data.get("use_layer", false)
	layer_mode.select(data.get("layer_mode", -1))
	layer_line.text = data.get("layer_id", "")
	layer_index.value = data.get("layer_index", 0)

	use_move.pressed = data.get("use_move", false)
	move_id.text = data.get("move_id", "")

	use_transition.pressed = data.get("use_transition", false)
	transition_type.select(data.get("transition_type", -1))
	transition_ease.select(data.get("transition_ease", -1))
	transition_time.value = data.get("transition_time", 0)
	transition_wait.pressed = data.get("transition_wait", false)

	use_transform.pressed = data.get("use_transform", false)
	transform_use_3d.pressed = data.get("transform_use_3d", false)

	origin_x.value = data.get("origin_x", 0)
	origin_y.value = data.get("origin_y", 0)
	origin_z.value = data.get("origin_z", 0)
	basis_x_x.value = data.get("basis_x_x", 0)
	basis_x_y.value = data.get("basis_x_y", 0)
	basis_x_z.value = data.get("basis_x_z", 0)
	basis_y_x.value = data.get("basis_y_x", 0)
	basis_y_y.value = data.get("basis_y_y", 0)
	basis_y_z.value = data.get("basis_y_z", 0)
	basis_z_x.value = data.get("basis_z_x", 0)
	basis_z_y.value = data.get("basis_z_y", 0)
	basis_z_z.value = data.get("basis_z_z", 0)




func parse(re_match: RegExMatch) -> void:
	var re: RegEx

	var actor_id := ""
	while re_match:
		actor_id = re_match.get_string("actor")
		actor.select(timeline.actors.keys().find(actor_id))
		match re_match.get_string("function"):
			"show":
				show.select(1)
			"hide":
				show.select(2)
			"play":
				#can we make this a function?
				# input dict with name as key and type as value
				use_animation.pressed = true
				var _re := _create_regex({"aniamtion": TYPE_STRING, "wait": TYPE_BOOL}).search(re_match.get_string("args"))
				if _re:
					animation.select = timeline.actors[actor_id].sprite.get_animation_list().find(_re.get_string("animation"))
					animation_wait.pressed = bool(_re.get_string("wait"))
			"behind":
				use_layer.pressed = true
				layer_mode.select(0)
				var _re := _create_regex({"target": TYPE_STRING}).search(re_match.get_string("args"))
				if _re:
					layer_line.text =_re.get_string("target").c_unescape()
			"front":
				use_layer.pressed = true
				layer_mode.select(1)
				var _re := _create_regex({"target": TYPE_STRING}).search(re_match.get_string("args"))
				if _re:
					layer_line.text =_re.get_string("target").c_unescape()
			"at":
				use_layer.pressed = true
				layer_mode.select(2)
				var _re := _create_regex({"target": TYPE_INT}).search(re_match.get_string("args"))
				if _re:
					layer_index.value = int(_re.get_string("target"))
			"move":
				use_move.pressed = true
				var _re := _create_regex({
					"position": TYPE_STRING,
					"transform": TYPE_TRANSFORM,
					"transition": TYPE_INT,
					"ease": TYPE_INT,
					"time": TYPE_REAL,
					"wait": TYPE_BOOL,
				}).search(re_match.get_string("args"))
				if _re:
					move_id.text = _re.get_string("position").c_unescape()
					match _re.get_string("transform"):
						"Transform", "Transform2D":
							use_transform.pressed = true
							basis_x_x.value = float(_re.get_string("xx"))
							basis_x_y.value = float(_re.get_string("xy"))
							basis_x_z.value = float(_re.get_string("xz"))
							basis_y_x.value = float(_re.get_string("yx"))
							basis_y_y.value = float(_re.get_string("yy"))
							basis_y_z.value = float(_re.get_string("yz"))
							basis_z_x.value = float(_re.get_string("zx"))
							basis_z_y.value = float(_re.get_string("zy"))
							basis_z_z.value = float(_re.get_string("zz"))
							origin_x.value = float(_re.get_string("ox"))
							origin_y.value = float(_re.get_string("oy"))
							origin_z.value = float(_re.get_string("oz"))
							continue
						"Transform":
							transform_use_3d.pressed = true
					var transition = int(_re.get_string("transition"))
					if transition >= 0:
						use_transition.pressed = true
					transition_type.select(transition)
					transition_time.value = float(_re.get_string("time"))
					transition_ease.select(int(_re.get_string("ease")))
					transition_wait.pressed = bool(_re.get_string("wait"))
		if !re:
			re = RegEx.new()
			re.compile(get_regex())
		re_match = re.search(re_match.get_string("next").lstrip("."))



static func get_regex() -> String:
	return "^(?<function>show|hide|behind|front|at|transform|play|move)\\(\\s*['\"](?<actor>\\w*)['\"]\\s*(?:,\\s*(?<args>(?:[^\\.{}]|\\\\\\.)+))?\\s*\\)\\s*(?<next>\\.\\s*\\g'1'\\(\\s*['\"]\\2['\"]\\s*(?:,\\s*(?:[^\\.]|\\\\\\.)+)?\\s*\\)\\g'next'?)?\\.?$"


func _on_TransformCheckBox_toggled(button_pressed: bool) -> void:
	get_data().use_transform = button_pressed
	transform_data.visible = button_pressed


func _on_ShowAtMode_item_selected(index: int) -> void:
	get_data().layer_mode = index
	match index:
		0, 1:
			layer_line.visible = true
			layer_index.visible = false
		2:
			layer_line.visible = false
			layer_index.visible = true


func _on_3D_toggled(button_pressed: bool) -> void:
	get_data().transform_use_3d = button_pressed
	origin_z.editable = button_pressed
	basis_x_z.editable = button_pressed
	basis_y_z.editable = button_pressed
	basis_z_x.editable = button_pressed
	basis_z_y.editable = button_pressed
	basis_z_z.editable = button_pressed


func get_code() -> String:
	var line := ""
	var actor_id: String = timeline.actors.keys()[actor.selected]

	match show.selected:
		1:#hide
			line += 'hide("%s").' % [actor_id.c_escape()]
		2:#show
			line += 'show("%s").' % [actor_id.c_escape()]

	if use_animation.pressed:
		line += 'play("%s", "%s", %s).' % [actor_id.c_escape(), timeline.actors[actor_id].sprite.get_animation_list()[animation.selected].c_escape(), str(animation_wait.pressed)]

	if use_move.pressed:
		line += 'position("%s", "%s").' % [actor_id.c_escape(), move_id.text.c_escape()]

	if use_layer.pressed:
		match layer_mode.selected:
			0:#Front
				line += 'front("%s", "%s").' % [actor_id.c_escape(), layer_line.text.c_escape()]
			1:#behind
				line += 'behind("%s", "%s").' % [actor_id.c_escape(), layer_line.text.c_escape()]
			2:#layer
				line += 'layer("%s", "%d").' % [actor_id.c_escape(), layer_index.value]

	if use_transform.pressed:
		var transform := ""
		if transform_use_3d.pressed:
			transform = 'Transform(Vector3(%r, %r, %r), Vector3(%r, %r, %r), Vector3(%r, %r, %r), Vector3(%r, %r, %r))' % [
					basis_x_x.value, basis_x_y.value, basis_x_z.value,
					basis_y_x.value, basis_y_y.value, basis_y_z.value,
					basis_z_x.value, basis_z_y.value, basis_z_z.value,
					origin_x.value, origin_y.value, origin_z.value
				]
		else:
			transform = 'Transfrom2D(Vector2(%r, %r), Vector2(%r, %r), Vector2(%r, %r))' % [
					basis_x_x.value, basis_x_y.value,
					basis_y_x.value, basis_y_y.value,
					origin_x.value, origin_y.value
				]
		line += 'move("%s", "%s", %s, %d, %d, %r, %b).' % [
				actor_id.c_escape(),
				move_id.text.c_escape(),
				transform if use_transform.pressed else -1,
				transition_type.selected,
				transition_ease.selected,
				transition_time.value,
				transition_wait.pressed
			]
	line = line.trim_suffix(".")
	return line


func _on_Actor_item_selected(index: int) -> void:
	get_data().actor = timeline.actors.keys()[index]
	animation.clear()
	var sprite = timeline.actors.values()[index].sprite
	if sprite:
		for i in sprite.get_animation_names():
			animation.add_item(i)


func _on_Move_Use_toggled(button_pressed: bool) -> void:
	get_data().use_move = button_pressed
	transforms.visible = button_pressed


func _create_regex(segments := {}) -> RegEx:
	var re := RegEx.new()
	var code := "^\\s*"
	var end := ""
	for i in segments:
		end += ")?"
		match segments[i]:
			TYPE_STRING:
				code += "(?:['\"](?<%s>\\w*)['\"]\\s*" % i
			TYPE_BOOL:
				code += "(?:(?<%s>true|false)\\s*" % i
			TYPE_INT:
				code += "(?:(?<%s>\\d+)\\s*" % i
			TYPE_REAL:
				code += "(?:(?<%s>\\(?_d*\\.)?\\d+)\\s*" % i
			TYPE_TRANSFORM, TYPE_TRANSFORM2D:
				var vector := "(?:\\s*Vector[23]\\(\\s*(?<%s>(?:\\d*\\.)?\\d+)\\s*,\\s*(?<%s>(?:\\d*\\.)?\\d+)\\s*(?:,\\s*(?<%s>(?:\\d*\\.)?\\d+)\\s*)?\\)\\s*)"
				code += "(?:(?<%s>Transform(?:2D)?)\\(%s,%s(?:,%s)?,%s\\)" % [i,
					vector % ["xx", "xy", "xz"],
					vector % ["yx", "yy", "yz"],
					vector % ["zx", "zy", "zz"],
					vector % ["ox", "oy", "oz"]
				]
			_:
				code += "(?:(?<%s>)\\s*" % i
		code += ",\\s*"
	code.trim_suffix(",\\s*")
	var err = re.compile(code + end)
	assert(err == OK)
	return re


func _on_Transition_toggled(pressed : bool) -> void:
	get_data().use_transition = pressed
	transition.visible = pressed


func _get_actor_name() -> String:
	return timeline.actors.keys()[actor.selected] if actor.selected >= 0 else ""


func _get_actor() -> Actor:
	var actor_name = _get_actor_name()
	return timeline.actors.get(actor_name, null)


func _get_sprite() -> SpriteFrames:
	var actor = _get_actor()
	return actor.sprite if actor else null


func _on_Show_item_selected(index: int) -> void:
	get_data().show = index


func _on_Animation_Use_toggled(button_pressed: bool) -> void:
	get_data().use_animation = button_pressed


func _on_Animation_ID_item_selected(index: int) -> void:
	_get_actor()
	var sprite = _get_sprite()
	get_data().animation_id = sprite.get_animation_names()[index] if sprite else ""


func _on_Animation_Wait_toggled(button_pressed: bool) -> void:
	get_data().animation_wait = button_pressed


func _on_Layer_Use_toggled(button_pressed: bool) -> void:
	get_data().use_layer = button_pressed


func _on_Layer_ID_text_changed(new_text: String) -> void:
	get_data().layer_id = new_text


func _on_Layer_Index_value_changed(value: float) -> void:
	get_data().layer_index = int(value)


func _on_Move_ID_text_changed(new_text: String) -> void:
	get_data().move_id = new_text


func _on_OX_value_changed(value: float) -> void:
	get_data().origin_x = value


func _on_OY_value_changed(value: float) -> void:
	get_data().origin_y = value


func _on_OZ_value_changed(value: float) -> void:
	get_data().origin_z = value


func _on_XX_value_changed(value: float) -> void:
	get_data().basis_x_x = value


func _on_XY_value_changed(value: float) -> void:
	get_data().basis_x_y = value


func _on_XZ_value_changed(value: float) -> void:
	get_data().basis_x_z = value


func _on_YX_value_changed(value: float) -> void:
	get_data().basis_y_x = value


func _on_YY_value_changed(value: float) -> void:
	get_data().basis_y_y = value


func _on_YZ_value_changed(value: float) -> void:
	get_data().basis_y_z = value


func _on_ZX_value_changed(value: float) -> void:
	get_data().basis_z_x = value


func _on_ZY_value_changed(value: float) -> void:
	get_data().basis_z_y = value


func _on_ZZ_value_changed(value: float) -> void:
	get_data().basis_z_z = value


func _on_Type_item_selected(index: int) -> void:
	get_data().transition_type = index


func _on_Ease_item_selected(index: int) -> void:
	get_data().transition_ease = index


func _on_Transition_Time_value_changed(value: float) -> void:
	get_data().transition_time = value


func _on_Transition_Wait_toggled(button_pressed: bool) -> void:
	get_data().transition_wait = button_pressed
