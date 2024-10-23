## An area3d with character and current player detection
class_name NodotArea3D extends Area3D

## Enable the node or not
@export var enabled: bool = true

signal character_body_entered(body: CharacterBody3D)
signal character_body_exited(body: CharacterBody3D)
signal current_player_body_entered(body: CharacterBody3D)
signal current_player_body_exited(body: CharacterBody3D)

func _init():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	
func _on_body_entered(body: Node3D):
	if enabled and body is NodotCharacter3D:
		character_body_entered.emit(body)
		if "is_current_player" in body and body.is_current_player:
			current_player_body_entered.emit(body)
	
func _on_body_exited(body: Node3D):
	if enabled and body is NodotCharacter3D:
		character_body_exited.emit(body)
		if "is_current_player" in body and body.is_current_player:
			current_player_body_exited.emit(body)
