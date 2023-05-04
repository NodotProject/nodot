class_name Fly3D extends Node3D

signal can_fly(Parent, model)

@export_category("Velocity Configs")
@export var default_speed : int = 2
@export var min_speed : int = 1
@export var max_speed : int = 5

@export_category("Rotation Action")
@export var time = 1.0
@export var Rotate = 1.0
@export_range(0, 180) var limit_rotation : int = 90


var velocity = Vector3()
var temp_default_speed

func _enter_tree():
	temp_default_speed = default_speed
	
	if get_parent() is CharacterBody3D:
		connect("can_fly", _fly)
	else:
		print_debug("Parent must have CharacterBody3D, no: ", get_parent())

func _fly(Parent, model):
	
	if !Parent.is_on_floor():
		
		get_input(model)
		
		Parent.set_velocity(velocity)
		Parent.move_and_slide()
	else:
		print_debug("Error is not identif, please, report to Z3R0_GT#3883")

func get_input(model):

	var input_dir = Input.get_vector("ui_fly_left", "ui_fly_right", "ui_fly_foward", "ui_fly_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if default_speed > max_speed:
		default_speed = max_speed
	elif default_speed < min_speed:
		default_speed = temp_default_speed
	
	if Input.is_action_pressed("ui_fly_increment"):
		default_speed += 1
	elif Input.is_action_pressed("ui_fly_decrement"):
		default_speed -= 1
	
	velocity.z = default_speed
	
	if Input.is_action_pressed("ui_fly_foward"):
		model.rotation_degrees.x += lerp_angle(rotation_degrees.x,Rotate, time)
		velocity.y += 1
	elif Input.is_action_pressed("ui_fly_back"):
		model.rotation_degrees.x += lerp_angle(rotation_degrees.x,-Rotate, time)
		velocity.y -= 1
	elif Input.is_action_pressed("ui_fly_left"):
		if !model.rotation_degrees.y >= limit_rotation:
			model.rotation_degrees.y += lerp_angle(rotation_degrees.y,Rotate, time)
			velocity.x += direction.x
	elif Input.is_action_pressed("ui_fly_right"):
		if !model.rotation_degrees.y <= -limit_rotation:
			model.rotation_degrees.y += lerp(rotation_degrees.y, -Rotate, time)
			velocity.x -= -direction.x
	else:
		velocity.x = 0 
		velocity.y = 0
	
	velocity.normalized() * default_speed
