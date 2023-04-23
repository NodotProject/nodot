extends Node3D

var DIR = "user://save.json"

func _physics_process(delta):
	
	if Input.is_action_just_pressed("save"):
		$SaveManager.emit_signal("save_archive", DIR)
	
	if Input.is_action_just_pressed("load"):
		$SaveManager.emit_signal("load_archive", DIR)
