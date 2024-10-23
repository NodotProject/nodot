## A node to manage and monitor a numeric value.
class_name Counter extends Nodot

## Use the minimum and maximum values to forcefully limit the value
@export var limit_values: bool = false
## The minimum value.
@export var min_value: float = 0.0
## The maximum value.
@export var max_value: float = 100.0
## The step size.
@export var step: float = 1.0
## The current value.
@export var value: float = 0.0

## Triggered when the value changes
signal value_changed(value: float)
## Triggered when the value increases
signal value_increased(value: float)
## Triggered when the value decreases
signal value_decreased(value: float)
## Triggered when the value is the minimum value
signal min_value_reached(value: float)
## Triggered when the value is the maximum value
signal max_value_reached(value: float)


## Set the value to a specific amount.
func set_value(new_value: float) -> void:
	var old_value = value

	if limit_values:
		value = clamp(new_value, min_value, max_value)
	else:
		value = new_value

	if value > old_value:
		value_increased.emit(value)
	elif value < old_value:
		value_decreased.emit(value)

	if value != old_value:
		value_changed.emit(value)
		
	if value == min_value:
		min_value_reached.emit(value)
	if value == max_value:
		max_value_reached.emit(value)


## Add an amount to the value.
func add(amount: float) -> void:
	set_value(value + amount)


## Remove an amount from the value.
func remove(amount: float) -> void:
	set_value(value - amount)


## Increase the value by the step value
func step_up() -> void:
	add(step)


## Decrease the value by the step value
func step_down() -> void:
	remove(step)
