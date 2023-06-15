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
	if body is NodotCharacter3D:
		emit_signal("character_body_entered", body)
		if body == PlayerManager.node:
			emit_signal("current_player_body_entered", body)
	
func _on_body_exited(body: Node3D):
	if body is NodotCharacter3D:
		emit_signal("current_player_body_entered", body)
		if body == PlayerManager.node:
			emit_signal("current_player_body_exited", body)
