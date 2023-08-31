@tool
## When the current player enters this area, the camera is overridden
class_name CameraArea3D extends NodotArea3D

## The camera to set to when triggered
@export var camera: Camera3D

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !camera:
		warnings.append("Requires a Camera3D as a child")
	return warnings

func _enter_tree():
	if !camera:
		camera = Nodot.get_first_child_of_type(self, Camera3D)
	connect("current_player_body_entered", _current_player_entered)
	connect("current_player_body_exited", _current_player_exited)

func _current_player_entered(body: NodotCharacter3D):
	if !enabled:
		return
		
	body.set_current_camera(camera)
	
func _current_player_exited(body: NodotCharacter3D):
	if !enabled:
		return
	
	# TODO: Add an option to forcefully set the player camera rotation
	body.reset_current_camera()
