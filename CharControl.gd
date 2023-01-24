tool
extends Button

signal request_name_change(old, new)
signal on_delete(char_name)

const default_sprite = preload("res://icon.png")

var actor: Actor setget _set_actor; func _set_actor(new):
	actor = new
	var err = actor.connect("changed", self, "load_from_actor")
	assert(err == OK)
	load_from_actor()
var old_name := ""

onready var name_line := $LineEdit
onready var sprite := $Sprite
onready var label := $Label


func set_name(new: String) -> void:
	name_line.text = new
	old_name = new


func load_from_actor() -> void:
	if label.theme and label.theme.is_connected("changed", self, "update"):
		label.theme.disconnect("changed", self, "update")

	if actor:
		if actor.sprite:
			var ac_sprite = actor.sprite
			sprite.texture = ac_sprite.get_frame(ac_sprite.get_animation_names()[0], 0)
		else:
			sprite.texture = default_sprite
		label.text = actor.name
		label.theme = actor.theme
		if label.theme and not label.theme.is_connected("changed", self, "update"):
			label.theme.connect("changed", self, "update")
	else:
		label.text = ""
		label.theme = null
		sprite.texture = default_sprite


func _on_LineEdit_focus_exited() -> void:
	if name_line.text and name_line.text != old_name:
		emit_signal("request_name_change", old_name, name_line.text)


func _on_Delete_pressed() -> void:
	emit_signal("on_delete", old_name)
	self.queue_free()
