@tool
## Plays a sound when the player character enters the area and stops it when they leave
class_name SFXArea3D extends Area3D

## Enable the sfx area
@export var enabled: bool = true
## Use pause instead of stop when deactivating
@export var use_pause: bool = true

var is_editor: bool = Engine.is_editor_hint()
var player: SFXPlayer3D

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !Nodot.get_first_child_of_type(self, SFXPlayer3D):
		warnings.append("Should contain at least one SFXPlayer3D")
	return warnings

func _enter_tree():
	player = Nodot.get_first_child_of_type(self, SFXPlayer3D)
	if is_editor or !enabled or !player: return
	
	connect("body_entered", _detect_character_and_play)
	connect("body_exited", _detect_character_and_stop)

func _detect_character_and_play(body: Node3D):
	if body is CharacterBody3D:
		action()
		
func _detect_character_and_stop(body: Node3D):
	if body is CharacterBody3D:
		deactivate()

## Play the sound
func action():
	if !enabled: return
	player.fade_in()

## Stop the sound
func deactivate():
	if !enabled: return
	player.fade_out(use_pause)
