## Debounce helper for calling functions
class_name Debouncer extends Node

var _target: Object
var fn: Callable
var delay: float
var timer: SceneTreeTimer

func _init(target: Object, fn: Callable, delay: float):
	_target = target
	self.fn = fn
	self.delay = delay

func bounce(...args):
	# A new timer is created on each bounce. The instance's `timer` property
	# will always point to the most recently created timer.
	var new_timer = Engine.get_main_loop().create_timer(delay)
	timer = new_timer
	# We pass the new timer instance to the timeout handler.
	new_timer.timeout.connect(_on_timeout.bind(args, new_timer))

func _on_timeout(args, timer_that_fired):
	# The callback only executes if the timer that fired is the most recent one.
	# If `bounce` was called again, `self.timer` would point to a different,
	# newer timer, and this check would fail for the older timer.
	if timer_that_fired == timer:
		fn.callv(args)
		# The timer is automatically freed after timeout. Nullify the reference
		# to prevent it from becoming a dangling pointer.
		timer = null
