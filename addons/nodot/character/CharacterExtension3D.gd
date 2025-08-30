# A base node to add extension logic to NodotCharacter3D
class_name CharacterExtensionBase3D extends StateHandler

@export var default: bool = false

var character: CharacterBody3D
var third_person_camera: ThirdPersonCamera

func _get_configuration_warnings():
	return [] if get_parent() is CharacterBody3D else ["This state should be a child of a CharacterBody3D."]

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		if character == null:
			character = get_parent()
		
		if get_parent() is NodotCharacter3D:
			if character.camera is ThirdPersonCamera:
				third_person_camera = character.camera
		
		_state_machine = character.sm
		_state_machine._available_states[name] = self
		
		if has_method("setup"):
			setup()

		if default and !_state_machine.state:
			_state_machine.transition(name)
			
## Override this
func setup():
	pass
