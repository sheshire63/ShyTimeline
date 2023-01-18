extends LineEdit


export var completion_list: PoolStringArray = []

onready var menu := PopupMenu.new()
var hover_index := 0
var suggestion_list: PoolStringArray = []

func _ready() -> void:
	connect("text_changed", self, "_on_text_entered")
	connect("focus_exited", self, "_on_focus_exited")
	add_child(menu)
	menu.popup_exclusive = true
	menu.connect("index_pressed", self, "_complete")


func _on_text_entered(text := "") -> void:
	suggestion_list = []
	hover_index = 0
	for i in completion_list:
		if text != "" and i.to_lower().begins_with(text.to_lower()):
			suggestion_list.append(i)
	
	if suggestion_list:
		menu.clear()
		for i in suggestion_list:
			menu.add_item(i)
		
		var pos = caret_position
		menu.popup(Rect2(Vector2(0, rect_size.y) + rect_global_position, Vector2(rect_size.x, menu.rect_size.y)))
		grab_focus()
		caret_position = pos


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var new: int
		if event.scancode == KEY_UP:
			new = hover_index - 1
		elif event.scancode == KEY_DOWN:
			new = hover_index + 1
		else:
			return
		hover_index = wrapi(new, 0, menu.get_item_count())
		menu.set_current_index(hover_index)


func _complete(index := 0) -> void:
	text = suggestion_list[index]


func _on_focus_exited() -> void:
	menu.hide()
