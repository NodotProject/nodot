## A simple signal class for global signals
extends Node

var signals: Dictionary = {}

## Add a listener for a specific key
func connect_signal(signal_name: StringName, callable: Callable) -> void:
	if not signals.has(signal_name):
		signals[signal_name] = [callable]
	else:
		signals[signal_name].append(callable)

## Remove a listener for a specific key
func disconnect_signal(signal_name: StringName, callable: Callable) -> void:
	if not signals.has(signal_name):
		return

	for i in range(signals[signal_name].size()):
		if signals[signal_name][i] == callable:
			signals[signal_name].remove_at(i)
			return

## Trigger a signal for a specific key
func emit(signal_name: StringName, ...arg):
	if not signals.has(signal_name):
		return

	for i in range(signals[signal_name].size()):
		var callable: Callable = signals[signal_name][i]
		if arg != null:
			callable.callv(arg)
		else:
			callable.call()
