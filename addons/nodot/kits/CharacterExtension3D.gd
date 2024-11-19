# A base node to add extension logic to NodotCharacter3D
class_name CharacterExtensionBase3D extends StateHandler

var character: NodotCharacter3D
var third_person_camera: ThirdPersonCamera

func _get_configuration_warnings():
	return [] if get_parent() is NodotCharacter3D else ["This state should be a child of a NodotCharacter3D."]

func _ready():
	if character == null and get_parent() is NodotCharacter3D:
		character = get_parent()
		if character.camera is ThirdPersonCamera:
			third_person_camera = character.camera
		
		_state_machine = character.sm
		_state_machine._available_states[name] = self
		
	if has_method("setup"):
		setup()

## Override this
func setup():
	pass
