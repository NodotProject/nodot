@tool
@icon("../icons/spray_pattern.svg")
## A customizable spray pattern node that defines and manages recoil and spray behaviors for firearms
class_name SprayPattern extends Node

## The curve defining the spray pattern where x-axis is shot index and y-axis is recoil offset
@export var base_curve: Curve2D: set = _set_base_curve
## Speed at which the view recenters after shooting stops
@export var recovery_speed: float = 5.0: set = _set_recovery_speed
## Speed at which recoil is applied
@export var apply_speed: float = 10.0: set = _set_apply_speed
## Additive randomness for vertical recoil (pitch)
@export var randomness_pitch: float = 0.1: set = _set_randomness_pitch
## Additive randomness for horizontal recoil (yaw)
@export var randomness_yaw: float = 0.1: set = _set_randomness_yaw
## Time in milliseconds before the pattern resets after shooting stops
@export var reset_after_ms: int = 500: set = _set_reset_after_ms
## Whether the pattern loops when it reaches the end
@export var loop_pattern: bool = false: set = _set_loop_pattern

## Emitted when spray offset is updated, contains the offset and current shot index
signal spray_offset_updated(offset: Vector2, shot_index: int)
## Emitted when the spray pattern resets after cooldown
signal pattern_reset

var current_shot_index: int = 0
var time_since_last_shot: float = 0.0
var current_offset: Vector2 = Vector2.ZERO
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var is_resetting: bool = false

func _ready() -> void:
	if not base_curve:
		_create_default_curve()
	rng.randomize()

func _physics_process(delta: float) -> void:
	time_since_last_shot += delta * 1000  # Convert to milliseconds
	
	# Check if we should reset the pattern
	if time_since_last_shot >= reset_after_ms and current_shot_index > 0:
		_reset_pattern()
	
	# Apply recovery if we're not shooting
	if is_resetting and recovery_speed > 0.0:
		current_offset = current_offset.move_toward(Vector2.ZERO, recovery_speed * delta)
		spray_offset_updated.emit(current_offset, current_shot_index)

## Get the next offset in the spray pattern
func get_next_offset() -> Vector2:
	if not base_curve:
		return Vector2.ZERO
	
	time_since_last_shot = 0.0
	is_resetting = false
	
	# Get base offset from curve
	var pattern_offset: Vector2 = Vector2.ZERO
	var point_count = base_curve.point_count
	
	if point_count > 0:
		var shot_index = current_shot_index
		
		# Handle looping
		if loop_pattern and point_count > 1:
			shot_index = shot_index % point_count
		elif shot_index >= point_count:
			shot_index = point_count - 1
		
		# Get the curve point
		if shot_index < point_count:
			var point = base_curve.get_point_position(shot_index)
			pattern_offset = Vector2(point.y, point.x)  # x=pitch, y=yaw in our coordinate system
	
	# Add randomness
	var random_pitch = rng.randf_range(-randomness_pitch, randomness_pitch)
	var random_yaw = rng.randf_range(-randomness_yaw, randomness_yaw)
	var random_offset = Vector2(random_pitch, random_yaw)
	
	# Apply the offset
	var total_offset = pattern_offset + random_offset
	current_offset += total_offset * apply_speed
	
	current_shot_index += 1
	
	spray_offset_updated.emit(current_offset, current_shot_index)
	return current_offset

## Reset the spray pattern to initial state
func reset_pattern() -> void:
	_reset_pattern()

## Get the current accumulated offset
func get_current_offset() -> Vector2:
	return current_offset

## Get the current shot index in the pattern
func get_current_shot_index() -> int:
	return current_shot_index

func _reset_pattern() -> void:
	current_shot_index = 0
	is_resetting = true
	pattern_reset.emit()

func _create_default_curve() -> void:
	base_curve = Curve2D.new()
	# Add some default points for a basic upward spray pattern
	base_curve.add_point(Vector2(0.0, 0.0))
	base_curve.add_point(Vector2(1.0, 0.1))
	base_curve.add_point(Vector2(2.0, 0.3))
	base_curve.add_point(Vector2(3.0, 0.6))
	base_curve.add_point(Vector2(4.0, 1.0))

# Setter functions for export variables
func _set_base_curve(value: Curve2D) -> void:
	base_curve = value

func _set_recovery_speed(value: float) -> void:
	recovery_speed = max(0.0, value)

func _set_apply_speed(value: float) -> void:
	apply_speed = max(0.1, value)

func _set_randomness_pitch(value: float) -> void:
	randomness_pitch = max(0.0, value)

func _set_randomness_yaw(value: float) -> void:
	randomness_yaw = max(0.0, value)

func _set_reset_after_ms(value: int) -> void:
	reset_after_ms = max(0, value)

func _set_loop_pattern(value: bool) -> void:
	loop_pattern = value