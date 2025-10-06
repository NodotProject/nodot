@tool
## When the current player enters this area, the current camera is overridden
class_name CameraArea3D extends NodotArea3D

## The camera to set to when triggered
@export var camera: Camera3D
## The time to wait before resetting the camera
@export var debounce_duration := 0.5

var _debouncer: Debouncer
var _body: NodotCharacter3D

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !camera:
		warnings.append("Requires a Camera3D as a child")
	return warnings

func _enter_tree():
	if !camera:
		camera = Nodot.get_first_child_of_type(self, Camera3D)
	_debouncer = Debouncer.new(_reset_camera, debounce_duration)
	connect("current_player_body_entered", _current_player_entered)
	connect("current_player_body_exited", _current_player_exited)
	
func _exit_tree() -> void:
	_reset_camera()

func _current_player_entered(body: NodotCharacter3D):
	if !enabled:
		return
	
	_body = body
	body.set_current_camera(camera)
	
func _current_player_exited(body: NodotCharacter3D):
	if !enabled:
		return
	
	_body = body
	_debouncer.bounce()

func _reset_camera():
	if _body:
		_body.reset_current_camera()
