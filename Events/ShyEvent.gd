extends Object
class_name ShyTimelineEvent


class ShyInput:
	var control : ShyValue
	var variable  : ShyValue
	var default : ShyValue
	export var property : NodePath

	func _get_property_list() -> Array:
		return [
			{
				"name": "control",
				"type": TYPE_OBJECT,
				"usage": PROPERTY_USAGE_STORAGE,
			},
			{
				"name": "variable",
				"type": TYPE_OBJECT,
				"usage": PROPERTY_USAGE_STORAGE,
			},
			{
				"name": "default",
				"type": TYPE_OBJECT,
				"usage": PROPERTY_USAGE_STORAGE,
			},
		]



var text_label : NodePath
var container : NodePath
var actor : String
var text : ShyValue
var items := []
var inputs := []

func _get_property_list() -> Array:
	return [
		{
				"name": "text_label",
				"type": TYPE_OBJECT,
				"usage": PROPERTY_USAGE_STORAGE,
		},
		{
				"name": "container",
				"type": TYPE_OBJECT,
				"usage": PROPERTY_USAGE_STORAGE,
		},
		{
				"name": "actor",
				"type": TYPE_OBJECT,
				"usage": PROPERTY_USAGE_STORAGE,
		},
		{
				"name": "text",
				"type": TYPE_OBJECT,
				"usage": PROPERTY_USAGE_STORAGE,
		},
		{
				"name": "items",
				"type": TYPE_ARRAY,
				"usage": PROPERTY_USAGE_STORAGE,
		},
		{
				"name": "inputs",
				"type": TYPE_ARRAY,
				"usage": PROPERTY_USAGE_STORAGE,
		},
		]

