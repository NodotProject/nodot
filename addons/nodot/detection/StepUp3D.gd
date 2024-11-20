class_name StepUp3D extends Node3D

@export var max_step_height: float = 0.25

@onready var character: CharacterBody3D = get_parent()

var target_y: float = 0.0
var is_stepping_up: bool = false

func _ready():
	target_y = character.global_transform.origin.y

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not get_parent() is CharacterBody3D:
		warnings.append("The parent should be a CharacterBody3D")
	return warnings

func _physics_process(delta: float):
	if character and character._is_on_floor():
		stair_step(delta)
		smooth_move(delta)

func stair_step(delta: float):
	var movement_vector: Vector3 = character.direction3d * delta
	movement_vector.y = 0  # Exclude vertical movement for step testing

	# Test if moving forward causes a collision
	if character.test_move(character.transform, movement_vector):
		# Attempt to step up
		var up_transform = character.transform.translated(Vector3(0, max_step_height, 0))
		if !character.test_move(up_transform, movement_vector):
			# Step up is possible
			target_y = up_transform.origin.y
			is_stepping_up = true
	else:
		# No collision, reset stepping up
		is_stepping_up = false
		target_y = character.global_transform.origin.y

func smooth_move(delta: float):
	if is_stepping_up:
		var current_y = character.global_transform.origin.y
		var new_y = lerp(current_y, target_y, 0.1)  # Adjust the factor as needed
		var vertical_movement = new_y - current_y
		character.velocity.y = vertical_movement / delta
