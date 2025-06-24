## A node that, when touched, the character is set to the "climb" state
class_name Ladder3D extends NodotArea3D

func _enter_tree():
	current_player_body_entered.connect(_on_current_player_body_entered)
	current_player_body_exited.connect(_on_current_player_body_exited)
	
func _on_current_player_body_entered(body: NodotCharacter3D):
	var climb_state_handler = Nodot.get_first_child_of_type(body, CharacterClimb3D)
	if climb_state_handler:
		body.sm.transition(climb_state_handler.name)
	
func _on_current_player_body_exited(body: NodotCharacter3D):
	var idle_state_handler = Nodot.get_first_child_of_type(body, CharacterIdle3D)
	if idle_state_handler:
		body.sm.transition(idle_state_handler.name)
