tool
extends Resource

class_name NodeData


# this data is set in the editor and used on save
#  so we need to load/save it in the graph data?
#  or recreate it based on the graph data
#  only store data that should be changed in the inspector
#   add the rest on save in the node
export var overwrite_text_box := false


func load_data(data := {}) -> void:
	overwrite_text_box = data.get("overwrite_text_box", overwrite_text_box)


func save_data() -> Dictionary:
	return {
		"overwrite_text_box": overwrite_text_box
	}