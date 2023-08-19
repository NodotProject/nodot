@icon("../icons/storage.svg")
## Redis-like class to store key-value pairs
class_name Storage extends Nodot

## Dictionary to store key-value pairs
@export var data: Dictionary = {}

var signals: Dictionary = {}

signal value_changed(key, new_value)
signal key_deleted(key)

## Method to set a value for a given key
func setItem(key, value):
	data[key] = value
	emit_signal("value_changed", key, value)
	trigger_signal(key, value)

## Method to get the value for a given key
func getItem(key):
	return data.get(key)

## Method to check if a key exists
func hasItem(key):
	return data.has(key)

## Method to delete a key-value pair
func deleteItem(key):
	if hasItem(key):
		var value = data[key]
		data.erase(key)
		emit_signal("key_deleted", key)
		trigger_signal(key, null)

## Add a listener for a specific key
func add_listener(signal_name: String, node: Node, method: StringName):
	if not signals.has(signal_name):
		signals[signal_name] = [{
			"node": node,
			"method": method
		}]
	else:
		signals[signal_name].append({
			"node": node,
			"method": method
		})

## Remove a listener for a specific key
func remove_listener(signal_name: String, node: Node, method: StringName):
	if not signals.has(signal_name):
		return

	for i in range(signals[signal_name].size()):
		var callable = signals[signal_name][i]
		if callable.node == node and callable.method == method:
			signals[signal_name].remove_at(i)
			return

## Trigger a signal for a specific key
func trigger_signal(signal_name: String, arg: Variant = null):
	if not signals.has(signal_name):
		return

	for i in range(signals[signal_name].size()):
		var target = signals[signal_name][i]
		if is_instance_valid(target.node) and target.node.has_method(target.method):
			var callable: Callable = target.node[target.method]
			callable.call(arg, signal_name)
