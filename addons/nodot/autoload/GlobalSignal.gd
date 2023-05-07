## A simple signal class for global signals
class_name GlobalSignal

var signals: Dictionary = {}

func connect(signal_name: String, callable: Callable, binds = []):
    if not signals.has(signal_name):
        signals[signal_name] = [{
			callable: callable,
			binds: binds
        }]
	else:
		signals[signal_name].append({
			callable: callable,
			binds: binds
		})

func disconnect(signal_name: String, callable: Callable):
	if not signals.has(signal_name):
		return

	for i in range(signals[signal_name].size()):
		if signals[signal_name][i].callable == callable:
			signals[signal_name].remove(i)
			return

func emit_signal(signal_name: String, args = []):
	if not signals.has(signal_name):
		return

	for i in range(signals[signal_name].size()):
		var callable = signals[signal_name][i].callable
		var binds = signals[signal_name][i].binds
		if is_instance_valid(callable):
			callable.call_funcv(binds + args)