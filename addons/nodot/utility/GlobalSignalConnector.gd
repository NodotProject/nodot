## Connects global signals to methods
class_name GlobalSignalConnector extends Nodot

## The name of the global signal
@export var trigger_signal: String = "signal"
## The node that has the method
@export var target_node: Node
## The name of the method
@export var target_method: String = "action"
## Arguments to unbind from signal
@export var unbind_count: int = 0


func _ready():
	if (
		is_instance_valid(target_node)
		and trigger_signal != ""
		and target_method != ""
	):
		var callback = target_node[target_method]
		if unbind_count > 0:
			callback = Callable(target_node[target_method].unbind(unbind_count))
		GlobalSignal.connect(trigger_signal, callback)
