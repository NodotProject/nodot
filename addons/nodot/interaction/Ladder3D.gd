## A node that, when touched, the character is set to the "climb" state
class_name Ladder3D extends NodotArea3D

func _enter_tree():
	connect("current_player_body_entered", _on_current_player_body_entered)
	connect("current_player_body_exited", _on_current_player_body_exited)
	
func _on_current_player_body_entered(body: NodotCharacter3D):
	body.sm.set_state(body.sm.get_id_from_name("climb"))
	
func _on_current_player_body_exited(body: NodotCharacter3D):
	body.sm.set_state(body.sm.get_id_from_name("idle"))
