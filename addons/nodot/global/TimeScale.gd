## A node that manages Engine.time_scale
class_name TimeScale extends Nodot

## A timescale variable synced with Engine.time_scale
@export var timescale: float = 1.0: set = _set_timescale

signal timescale_changed(timescale: float)

var target_timescale: float = 1.0
var smooth_step: float = 0.01

func _physics_process(_delta):
	timescale = lerp(timescale, target_timescale, smooth_step)

func _set_timescale(new_timescale: float):
	if timescale == new_timescale:
		return
		
	timescale = new_timescale
	Engine.time_scale = timescale
	emit_signal("timescale_changed", timescale)

## Set the timescale
func set_timescale(new_timescale: float):
	_set_timescale(new_timescale)
	
## Set a target timescale to lerp to
func smooth_timescale_to(new_timescale: float, step: float = 0.01):
	target_timescale = new_timescale
	smooth_step = step
	
