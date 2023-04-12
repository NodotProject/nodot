## Connects signals to methods
class_name SignalConnector extends Nodot

## The node that will emit the signal
@export var trigger_node: Node
## The name of the signal
@export var trigger_signal: String = "interacted"
## The node that has the method
@export var target_node: Node
## The name of the method
@export var target_method: String = "action"
## (optional) The number of arguments in the method to ignore
@export var ignored_arguments: int = 0

func _ready():
  if is_instance_valid(trigger_node) and is_instance_valid(target_node) and trigger_signal != "" and target_method != "":
    if ignored_arguments > 0:
      var callable = Callable(target_node, target_method)
      trigger_node.connect(trigger_signal, callable.unbind(ignored_arguments))
    else:
      trigger_node.connect(trigger_signal, target_node[target_method])
  
