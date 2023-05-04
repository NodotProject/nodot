## This node is a mechanic for fly player (experimental)
class_name Fly3D extends Node3D

## This signal call in "_physics_process()" of player: $(Fly3D).emit_signal("config_fly", self, $(model of player))
signal config_fly(Parent, model)

@export_category("Configs Funcs")
## Can rotate model of player
@export var can_rotate = true
## when scene start, move is automatic
@export var automatic_move = false
## Check when it can start to fly
@export var limit_high = 2.0


@export_category("Velocity Configs")
## always speed
@export var default_speed : int = 2
## min of speed
@export var min_speed : int = 1
## max of speed
@export var max_speed : int = 5

@export_category("Rotation Action")
## Frame x second to rotate model
@export var time_to_rot = 1.0
## Grades for rotate
@export var rotate_grade = 1.0
## Conditional for rotate model (grades)
@export_range(0, 180) var limit_rotation : int = 90

## Local velocity
var velocity = Vector3()
## Temp space from default speed
var temp_default_speed

func _enter_tree():
	temp_default_speed = default_speed
	
	if get_parent() is CharacterBody3D:
		connect("config_fly", _fly)
	else:
		print_debug("Parent must have CharacterBody3D, no: ", get_parent())

func _fly(Parent, model):
	
	## Check if can start to fly
	if !Parent.is_on_floor() and Parent.position.y >= limit_high:
		
		get_input(model)
		
		## send local velocity
		Parent.set_velocity(velocity)
		## local move and slide
		Parent.move_and_slide()
	else:
		return
	
func get_input(model):
	## Config new controlls
	var input_dir = Input.get_vector("ui_fly_left", "ui_fly_right", "ui_fly_foward", "ui_fly_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	##  Check limit of default speed
	if default_speed > max_speed:
		default_speed = max_speed
	elif default_speed < min_speed:
		default_speed = temp_default_speed
	
	## decrement or increment high or velocity in func of "automatic_move"
	if Input.is_action_pressed("ui_fly_increment"):
		if automatic_move:
			default_speed += 1
		else:
			velocity.y += 1
	elif Input.is_action_pressed("ui_fly_decrement"):
		if automatic_move:
			default_speed -= 1
		else:
			velocity.y -= 1
	else:
		velocity.y = 0
	
	## set automatic move
	if automatic_move:
		velocity.z = default_speed
	
	
	## Separate movement rotation by checker in two cases: "ui_fly_foward" and "ui_fly_back"
	if Input.is_action_pressed("ui_fly_foward"):
		if can_rotate:
			model.rotation_degrees.x += lerp_angle(rotation_degrees.x,rotate_grade, time_to_rot)
		
		if automatic_move:
			velocity.y += 1
		else:
			## Speed limit to avoid skidding or excessive movement
			if velocity.z <= max_speed:
				velocity.z = max_speed
			else:
				velocity.z += -direction.z
	elif Input.is_action_pressed("ui_fly_back"):
		if can_rotate:
			model.rotation_degrees.x += lerp_angle(rotation_degrees.x,-rotate_grade, time_to_rot)
		
		if automatic_move:
			velocity.y -= 1
		else:
			## Speed limit to avoid skidding or excessive movement
			if velocity.z <= -max_speed:
				velocity.z = -max_speed
			else:
				velocity.z -= direction.z
	elif Input.is_action_pressed("ui_fly_right"):
		if !model.rotation_degrees.y >= limit_rotation and can_rotate:
			model.rotation_degrees.y += lerp_angle(rotation_degrees.y,rotate_grade, time_to_rot)
		
		## Speed limit to avoid skidding or excessive movement
		if velocity.x <= max_speed:
			velocity.x = max_speed
		else:
			velocity.x += direction.x
	elif Input.is_action_pressed("ui_fly_left"):
		if !model.rotation_degrees.y <= -limit_rotation and can_rotate:
			model.rotation_degrees.y += lerp(rotation_degrees.y, -rotate_grade, time_to_rot)
		
		## Speed limit to avoid skidding or excessive movement
		if velocity.x <= -max_speed:
			velocity.x = -max_speed
		else:
			velocity.x -= -direction.x
		
	else:
		## Set velocity to 0 (in automatic or not)
		if automatic_move:
			velocity.y = 0
			velocity.x = 0
		else:
			velocity.x = 0
			velocity.z = 0
	
	#Formmated velocity before send
	velocity.normalized() * default_speed
