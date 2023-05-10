# A node to manage movement of a CharacterBody.
class_name CharacterMover extends Nodot

# Enable/disable this node.
@export var enabled : bool = true
# Enables stepping up stairs.
@export var stepping_enabled : bool = true
# Maximum height for a ledge to allow stepping up.
@export var step_height : float = 1.0
# Constructs the step up movement vector.
@onready var step_vector : Vector3 = Vector3(0,step_height,0)

var parent : CharacterBody3D


func _ready():
	if get_parent() is CharacterBody3D:
		parent = get_parent()
	else:
		enabled = false


func move() -> void:
	if !parent._is_on_floor() or parent.velocity.y > 0:
		move_air()
	else:
		move_ground()

func move_air() -> void:
	parent.move_and_slide()

func move_ground() -> void:
	if !enabled: return
	var starting_position : Vector3 = parent.global_position
	var starting_velocity : Vector3 = parent.velocity
	
	# Start by moving our character body by its normal velocity.
	parent.move_and_slide()
	if !stepping_enabled or !parent._is_on_floor(): return
	# Next, we store the resulting position for later, and reset our character's
	#    position and velocity values.
	var slide_position : Vector3 = parent.global_position
	parent.global_position = starting_position
	parent.velocity = Vector3(starting_velocity.x,0.0,starting_velocity.z)
	# After that, we move_and_collide() them up by step_height, move_and_slide()
	#    and move_and_collide() back down
	parent.move_and_collide(step_vector)
	parent.move_and_slide()
	parent.move_and_collide(-step_vector)
	# Finally, we test move down to see if they'll touch the floor once we move
	#    them back down to their starting Y-position, if not, they fall,
	#    otherwise, they step down by -step_height.
	if !parent.test_move(parent.global_transform,-step_vector):
		parent.move_and_collide(-step_vector)
	# Now that we've done all that, we get the distance moved for both movements
	#    and go with whichever one moves us further, as overhangs could impede 
	#    movement if we were to only step.
	var slide_distance : float = starting_position.distance_to(slide_position)
	var step_distance : float = starting_position.distance_to(parent.global_position)
	if slide_distance > step_distance or !parent._is_on_floor():
		parent.global_position = slide_position

