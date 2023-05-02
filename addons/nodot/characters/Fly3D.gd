class_name Fly3D extends Node

signal can_fly
signal not_fly

var target_add = get_parent()

func _enter_tree():
	
	connect("not_fly", _not_fly)
	
	if target_add is CharacterBody3D:
		connect("can_fly", _fly)
	else:
		print_debug("Parent must have CharacterBody3D, no: " + target_add)

func _fly():
	# can fly! :D
	
	pass

func _not_fly():
	
	#Not fly, :c
	
	pass
