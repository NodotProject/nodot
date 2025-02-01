class_name NodotRigidBody3D extends RigidBody3D

signal character_enter(body: CharacterBody3D)

func focussed() -> void:
	for child in get_children():
		if child.has_method("focussed"):
			child.focussed()

func unfocussed() -> void:
	for child in get_children():
		if child.has_method("unfocussed"):
			child.unfocussed()

func _on_character_entered(body: CharacterBody3D):
	character_enter.emit(body)
