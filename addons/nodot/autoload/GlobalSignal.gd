## A simple signal class for global signals
extends Node

var signals: Dictionary = {}

## Add a listener for a specific key
func add_listener(signal_name: String, node: Node, method: StringName):
	if not signals.has(signal_name):
		signals[signal_name] = [ {
			"node": node,
			"method": method
		}]
	else:
		signals[signal_name].append({
			"node": node,
			"method": method
		})

## Remove a listener for a specific key
func remove_listener(signal_name: String, callable: Callable):
	if not signals.has(signal_name):
		return

	for i in range(signals[signal_name].size()):
		if signals[signal_name][i].callable == callable:
			signals[signal_name].remove(i)
			return

## Trigger a signal for a specific key
func trigger_signal(signal_name: String, arg: Variant = null):
	if not signals.has(signal_name):
		return

	for i in range(signals[signal_name].size()):
		var target = signals[signal_name][i]
		if is_instance_valid(target.node) and target.node.has_method(target.method):
			var callable: Callable = target.node[target.method]
			if arg != null:
				callable.call(arg)
			else:
				callable.call()
