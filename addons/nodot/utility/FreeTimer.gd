## A timer that can be used to queue_free a node after a certain amount of time
class_name FreeTimer extends Nodot

## Whether the FreeTimer is enabled or not
@export var enabled: bool = true
## The target to `queue_free` on timeout
@export var target: Node
## Whether to start the timer on ready
@export var autostart: bool = false
## The time to wait before triggering `queue_free` on the target node
@export var wait_time: float = 1.0

func _ready():
	if enabled and autostart:
		action()
	
	if !target:
		target = get_parent()

func action():
	if !enabled:
		return
		
	await get_tree().create_timer(wait_time, false).timeout
	target.queue_free()
	
