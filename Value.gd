class_name ShyValue
extends Object

# strore everything as dictionary and use funcs to get them
export var data := {}

func set_value(value) -> void:
	data.value = value

func set_weight(weight) -> void:
	data.weight = weight


func add_conditions(condition) -> void:
	if !data.has("conditions"):
		data.conditions = []
	data.conditions.append(condition)


func set_preffix(prefix) -> void:
	data.prefix = prefix


func set_suffix(suffix) -> void:
	data.suffix = suffix


func add_next_node(node) -> void:
	if !data.has("nodes"):
		data.nodes = []
	data.nodes.append(node)


func get_value(instance, variables := {}):
	var value
	if data.has("value"):
		value = data.value
		var expression = Expression.new()
		if value is String:
			var error = expression.parse(value, variables.keys())
		value = expression.execute(variables.values(), instance, false)
		if expression.has_execute_failed():
			print("failed to execute: %s" % [data.value])
			value = ""

	if value as ShyValue:
		sync_value(value)
		value = value.get_value(instance, variables)

	if "pre" in data or "suf" in data:
		var pre = data.get("pre", "")
		if pre as ShyValue:
			sync_value(pre)
			pre = pre.get_value(instance, variables)
		var suf = data.get("suf", "")
		if suf as ShyValue:
			sync_value(suf)
			suf = suf.get_value(instance, variables)
		return str(pre) + str(value) + str(suf)

	if value as Array:
		var total := 0.0
		var defaults := 0
		var values := []
		var weights := []
		for i in value:
			if i as ShyValue and !i.check_conditions(instance, variables):
				continue
			var weight
			if i as ShyValue and i.has_weight():
				weight = i.get_weight(instance, variables)
				total += weight
			else:
				defaults += 1
			values.append(i)
			weights.append(weight)
		var default = max(0, (1 - total) / defaults) if defaults else 0
		var random = rand_range(0.0, total)
		for i in values.size():
			random -= weights[i] if weights[i] != null else default
			if random <= 0.0:
				if values[i] as ShyValue:
					sync_value(values[i])
					return values[i].get_value(instance, variables)
				else:
					return values[i]
		data.nodes = []
		return ""


func get_weight(instance, variables := {}):
	if data.has("weight"):
		return float(data.weight.get_value(instance, variables) if data.weight as ShyValue else data.weight)
	return null


func has_weight() -> bool:
	return data.has("weight")


func check_conditions(instance, variables) -> bool:
	if data.has("conditions"):
		var res = true
		for i in data.conditions:
			res = bool(data.condition.get_value(instance, variables) if data.condition as ShyValue else data.condition)
			if !res:
				return false
	return true


func sync_value(value: ShyValue) -> void:
	if value and value.has("nodes"):
		if !data.has("nodes"):
			data.nodes = []
		data.nodes += value.nodes
