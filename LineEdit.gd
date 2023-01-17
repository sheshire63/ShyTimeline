tool
extends TextEdit
class_name TextEditT

# changed that a tab key is used to switch focus instead of entering the letter

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_TAB:
			if Input.is_key_pressed(KEY_SHIFT):
				find_prev_valid_focus().grab_focus()
			else:
				find_next_valid_focus().grab_focus()
			get_tree().set_input_as_handled()

