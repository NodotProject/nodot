class_name ScreenShake3D extends Nodot

## (optional) select the camera to apply the affect to. Will use the parent if not present.
@export var camera: Camera3D
## (optional) select the character to apply the affect to. Will use the parent if not present.
@export var character: NodotCharacter3D
## The intensity of the shake
@export var intensity: float = 0.5
## The time it takes to reduce the intensity to zero (in seconds)
@export var timespan: float = 1.0
## Shake noise
@export var noise: FastNoiseLite

var final_cameras: Array[Camera3D]
var initial_positions: Array[Vector3]
var initial_time: float = 0.0
var initial_intensity: float = 0.0
var current_time: float = 0.0
var current_intensity: float = 0.0
var is_active: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	_get_camera()


func _get_camera():
	var parent = get_parent()

	if character:
		_set_character_cameras(character)
	elif camera:
		final_cameras = [camera]
		initial_positions = [camera.position]
	elif parent is NodotCharacter3D:
		_set_character_cameras(parent)
	elif parent is Camera3D:
		final_cameras = [parent]
		initial_positions = [parent.position]
		


func _physics_process(delta: float):
	if current_time > 0.0:
		current_time -= delta
		
	var diff = current_time / initial_time * 100
	if current_intensity > 0.0:
		var shake = noise.get_noise_1d(current_time * 10.0) * current_intensity
		
		for final_camera in final_cameras:
			final_camera.rotation.z = shake
		current_intensity = initial_intensity / 100 * diff
	elif is_active:
		is_active = false
		for final_camera in final_cameras:
			final_camera.rotation.z = 0.0

func _set_character_cameras(character: NodotCharacter3D):
	final_cameras.append(character.camera)
	initial_positions = [character.camera.position]


## Trigger the camera shake. Passed arguments will override node settings.
func action(intensity_override: float = intensity, timespan_override: float = timespan):
	is_active = true
	initial_intensity = intensity_override
	initial_time = timespan_override
	current_intensity = intensity_override
	current_time = timespan_override
