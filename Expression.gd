extends Expression
class_name ShyExpression


signal completed

var regex_brackets := RegEx.new()
var regex_sections := RegEx.new()

var variables: Dictionary
var instance: Object
var is_running := false


func _init() -> void:
	# returns the content of {} brackets
	var err = regex_brackets.compile("(?<!\\\\){(?<result>(?:[^{}]|\\\\[{}])*)}")
	assert(err == OK)
	err = regex_sections.compile("^(?:(?<condition>.*?)\\?)?(?<value>.*?)(?::(?<weight>.*?))?(?:!(?<next>.*?))?$")
	assert(err == OK)



func handle(line: String, vars := {}, inst = null) -> void:
	is_running = true
	variables = vars
	instance = inst
	line = solve_bracket(line)

	if parse(line, variables.keys()) == OK:
		var result = execute(variables.values(), instance, false)
		if result is GDScriptFunctionState and result.is_valid():
			yield(result, "completed")
		if has_execute_failed():
			printerr("execute_failed: Line %s" % line)
	else:
		printerr("parse failed: Line %s" % line)
	emit_signal("completed")
	is_running = false


func solve_bracket(string: String) -> String:
	while true:
		var re_match = regex_brackets.search(string)
		if !re_match:
			break
		var inner = re_match.get_string("result")

		var weighted_values = {}
		var unweighted_values = []
		var total_weight := 0.0

		for section in inner.split(";"):
			var inner_match = regex_sections.search(section)
			var value = inner_match.names
			for i in value:
				value[i] = inner_match.get_string(i)
			if !value.has("condition") or _inner_handle(value.condition):
				if value.has("weight"):
					var weight = float(_inner_handle(value.weight))
					weighted_values[value] = weight
					total_weight += weight
				else:
					unweighted_values.append(value)

		var random := randf() * max(total_weight, 1.0)
		var result := ""
		for value in weighted_values:
			random -= weighted_values[value]
			if random <= 0.0:
				result = _handle_value(value)
		if unweighted_values and random > 0.0:
			result = _handle_value(unweighted_values[rand_range(0, unweighted_values.size())])
		string = string.left(re_match.get_start("result") - 1) + result + string.right(re_match.get_end("result") + 1)
	return string


#todo split for bool and float, string
func _inner_handle(string: String):
	if parse(string, variables.keys()) == OK:
		var result = execute(variables.values(), instance, false)
		if !has_execute_failed():
			return result
	printerr("failed to parse: %s" % [string])
	return ""


func _handle_value(value: Dictionary):
	var result = _inner_handle(value.value) if value.has("value") else ""
	if value.has("next"):
		var next = _inner_handle(value.next)#todo rework this we might want it to be a list of actions -> how to seperate entries -> stringArray
		if next and instance.has_method("queue_event"):
			instance.queue_event(next)
	return result
