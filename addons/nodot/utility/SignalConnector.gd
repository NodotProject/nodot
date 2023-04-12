class_name SignalConnector extends Nodot

@export var trigger_node: Node
@export var trigger_signal: String = "interacted"
@export var target_node: Node
@export var target_method: String = "action"
@export var ignored_arguments: int = 0

func _ready():
  if is_instance_valid(trigger_node) and is_instance_valid(target_node) and trigger_signal != "" and target_method != "":
    if ignored_arguments > 0:
      var callable = Callable(target_node, target_method)
      trigger_node.connect(trigger_signal, callable.unbind(ignored_arguments))
    else:
      trigger_node.connect(trigger_signal, target_node[target_method])
  
