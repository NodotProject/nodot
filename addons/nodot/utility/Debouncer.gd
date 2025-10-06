## Debounce helper for calling functions.
##
## This class creates a debounced version of the passed-in function `fn`.
## The debounced function will only be called after `delay` seconds have
## passed without any new calls to the function.
##
## [b]Usage Example:[/b]
## [codeblock]
## var debouncer: Debouncer
##
## func _ready():
##     debouncer = Debouncer.new(_on_search_text_changed, 0.5)
##     add_child(debouncer)
##     $LineEdit.text_changed.connect(debouncer.bounce)
##
## func _on_search_text_changed(new_text: String):
##     print("Searching for: ", new_text)
## [/codeblock]
class_name Debouncer extends Node

## The function to be debounced.
var _fn: Callable
## The debounce delay in seconds.
var _delay: float
## The active timer.
var timer: SceneTreeTimer

## Initializes the debouncer.
##
## [param fn] The function to be debounced.
## [param delay] The debounce delay in seconds.
func _init(fn: Callable, delay: float):
	_fn = fn
	_delay = delay

## Calls the debounced function.
##
## Each call to this function resets the debounce timer.
##
## [param ...args] The arguments to be passed to the debounced function.
func bounce(...args):
	# A new timer is created on each bounce. The instance's `timer` property
	# will always point to the most recently created timer.
	var new_timer = Engine.get_main_loop().create_timer(_delay)
	timer = new_timer
	# We pass the new timer instance to the timeout handler.
	new_timer.timeout.connect(_on_timeout.bind(args, new_timer))

## Called when the debounce timer times out.
##
## This function calls the debounced function if the timer that fired is the
## most recent one.
##
## [param args] The arguments to be passed to the debounced function.
## [param timer_that_fired] The timer that fired.
func _on_timeout(args, timer_that_fired):
	# The callback only executes if the timer that fired is the most recent one.
	# If `bounce` was called again, `timer` would point to a different,
	# newer timer, and this check would fail for the older timer.
	if timer_that_fired == timer:
		_fn.callv(args)
		# The timer is automatically freed after timeout. Nullify the reference
		# to prevent it from becoming a dangling pointer.
		timer = null
