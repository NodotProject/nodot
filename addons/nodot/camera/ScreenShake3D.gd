class_name ScreenShake3D extends Nodot

## (optional) select the camera to apply the affect to. Will use the parent if not present.
@export var camera: Camera3D
## (optional) select the character to apply the affect to. Will use the parent if not present.
@export var character: NodotCharacter3D
## The intensity of the shake
@export var intensity: float = 1.0
## The time it takes to reduce the intensity to zero (in seconds)
@export var timespan: float = 1.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var final_camera: Camera3D
var initial_position: Vector3
var initial_time: float = 0.0
var initial_intensity: float = 0.0
var current_time: float = 0.0
var current_intensity: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	_get_camera()


func _get_camera():
	var parent = get_parent()

	if character:
		final_camera = character.camera
	elif camera:
		final_camera = camera
	elif parent is NodotCharacter3D:
		final_camera = parent.camera
	elif parent is Camera3D:
		final_camera = parent
		
	initial_position = final_camera.position


func _physics_process(delta: float):
	if current_time > 0.0:
		current_time -= delta
	var diff = delta / current_time * initial_time
	if current_intensity > 0.0:
		var shake = (
			Vector3(
				rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)
			)
			* current_intensity
		)
		final_camera.position += shake
		current_intensity = initial_intensity * (1.0 - diff)
		


## Trigger the camera shake. Passed arguments will override node settings.
func action(intensity_override: float = intensity, timespan_override: float = timespan):
	initial_intensity = intensity_override
	initial_time = timespan_override
	current_intensity = intensity_override
	current_time = timespan_override
