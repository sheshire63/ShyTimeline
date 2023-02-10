tool
extends Resource
class_name Actor

export var name := ""
export var theme: Theme setget _set_theme; func _set_theme(new):
	if theme and theme.is_connected("changed", self, "changed"):
		theme.disconnect("changed", self, "changed")
	theme = new
	theme.connect("changed", self, "changed")
export var sprite: SpriteFrames setget _set_sprite; func _set_sprite(new):
	if sprite and sprite.is_connected("changed", self, "changed"):
		sprite.disconnect("changed", self, "changed")
	sprite = new
	sprite.connect("changed", self, "changed")
