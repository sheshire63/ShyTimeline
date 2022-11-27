extends Resource

class_name ShyUndo

var undo_history := []
var undo_future := []
var do_history := []
var do_future := []

var do_stack := []
var undo_stack := []

#todo check if the value is already set in the stack
func add_do(object, property: String, value) -> void:
	do_stack.append({"object": object, "property": property, "value": value})


func add_undo(object, property: String, value) -> void:
	undo_stack.append({"object": object, "property": property, "value": value})


func add_do_method(object, method: String, args := []) -> void:
	do_stack.append({"object": object, "method": method, "args": args})


func add_undo_method(object, method: String, args := []) -> void:
	undo_stack.append({"object": object, "method": method, "args": args})


func commit() -> void:
	if do_stack or undo_stack:
		undo_history.append(undo_stack)
		do_history.append(do_stack)
		undo_future = []
		do_future = []
		undo_stack = []
		do_stack = []
#todo add undo for methods
# check if the entry has method od property
# reference should be automatic thanks to ref count?

func undo() -> void:
	if do_history and undo_history:
		do_future.append(do_history.pop_back())
		var undo = undo_history.pop_back()
		for i in undo:
			if i.has("property"):
				i.object[i.property] = i.value
			else:
				i.object.callv(i.method, i.args)
		undo_future.append(undo)


func redo() -> void:
	if do_future and undo_future:
		undo_history.append(undo_future.pop_back())
		var do = do_future.pop_back()
		for i in do:
			if i.has("property"):
				i.object[i.property] = i.value
			else:
				i.object.callv(i.method, i.args)
		do_history.append(do)
