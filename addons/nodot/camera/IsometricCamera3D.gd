## A camera angled at 45 degrees from above
class_name IsometricCamera3D extends Camera3D

## Enable movement and interaction
@export var enabled: bool = false
## The height of the camera (in global Y coordinates)
@export var height: float = 10.0
## Whether the camera can rotate
@export var can_rotate: bool = true
## Whether the camera can zoom
@export var can_zoom: bool = true
## The movement speed
@export var movement_speed: float = 2.0
## The stopping speed
@export var movement_friction: float = 1.5
## The rotation speed
@export var rotation_speed: float = 0.66
## The zoom speed
@export var zoom_speed: float = 20.0


@export_category("Input Actions")
@export var left_action: String = "isometric_camera_left"
@export var right_action: String = "isometric_camera_right"
@export var up_action: String = "isometric_camera_forward"
@export var down_action: String = "isometric_camera_backwards"
@export var rotate_left_action: String = "isometric_camera_rotate_left"
@export var rotate_right_action: String = "isometric_camera_rotate_right"
@export var zoom_in_action: String = "isometric_camera_zoom_in"
@export var zoom_out_action: String = "isometric_camera_zoom_out"

var velocity: Vector3 = Vector3.ZERO
var zoom_velocity: Vector3 = Vector3.ZERO

func _init():
	register_key_actions()
	register_mouse_actions()
	top_level = true

func _ready():
	global_position.y = height
	rotation.x = 0 - PI / 4
	
func _physics_process(delta):
	if !enabled: return
	
	var input_dir = Input.get_vector(left_action, right_action, up_action, down_action)
	var direction = (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction == Vector3.ZERO:
		velocity.x = move_toward(velocity.x, 0, movement_friction * delta)
		velocity.z = move_toward(velocity.z, 0, movement_friction * delta)
	else:
		velocity.x = lerp(velocity.x, direction.x, movement_speed * delta)
		velocity.z = lerp(velocity.z, direction.z, movement_speed * delta)
	
	if can_rotate:
		if Input.is_action_pressed(rotate_left_action):
			rotation.y += rotation_speed * delta
		if Input.is_action_pressed(rotate_right_action):
			rotation.y -= rotation_speed * delta
	
	if can_zoom:
		if Input.is_action_just_pressed(zoom_in_action):
			zoom_velocity = -global_transform.basis.z * zoom_speed * delta
		if Input.is_action_just_pressed(zoom_out_action):
			zoom_velocity = global_transform.basis.z * zoom_speed * delta
		zoom_velocity = lerp(zoom_velocity, Vector3.ZERO, (zoom_speed / 2) * delta)
		
	position += (velocity + zoom_velocity)

func register_key_actions():
	var action_names = [left_action, right_action, up_action, down_action, rotate_left_action, rotate_right_action]
	var default_keys = [
		KEY_A, KEY_D, KEY_W, KEY_S, KEY_BRACKETLEFT, KEY_BRACKETRIGHT
	]
	for i in action_names.size():
		var action_name = action_names[i]
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			InputManager.add_action_event_key(action_name, default_keys[i])
			
func register_mouse_actions():
	var action_names = [zoom_in_action, zoom_out_action]
	var default_keys = [
		MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN
	]
	for i in action_names.size():
		var action_name = action_names[i]
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			InputManager.add_action_event_mouse(action_name, default_keys[i])
			
