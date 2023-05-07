## Proxies local signals to global signals
class_name LocalToGlobalSignalProxy extends Nodot

## The node that will emit the signal
@export var trigger_node: Node
## The name of the signal
@export var trigger_signal: String = ""
## The global signal name
@export var global_signal: String = ""
## Arguments to unbind from signal
@export var unbind_count: int = 0


func _ready():
	if (
		is_instance_valid(trigger_node)
		and trigger_signal != ""
		and global_signal != ""
	):
		var callback = _callback
		if unbind_count > 0:
			callback = Callable(_callback.unbind(unbind_count))
		trigger_node.connect(trigger_signal, callback)

func _callback():
	GlobalSignal.trigger_signal(global_signal)
