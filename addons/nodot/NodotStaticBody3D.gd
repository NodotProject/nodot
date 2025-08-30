@tool

class_name NodotStaticBody3D extends StaticBody3D

@export var navigation_obstacle_mesh: MeshInstance3D:
	set(new_value):
		navigation_obstacle_mesh = new_value
		_spawn_navigation_obstacle()

var is_editor := Engine.is_editor_hint()

func _on_enter_tree():
	_spawn_navigation_obstacle()

func _spawn_navigation_obstacle():
	if !is_editor: return
	for child in get_children():
		if child is NavigationObstacle3D:
			child.queue_free()
	if navigation_obstacle_mesh and navigation_obstacle_mesh.mesh:
		var aabb = navigation_obstacle_mesh.mesh.get_aabb()
		var radius = max(aabb.size.x, aabb.size.z) * 0.5
		var height = aabb.size.y
		var nav_obstacle = NavigationObstacle3D.new()
		nav_obstacle.affect_navigation_mesh = true
		nav_obstacle.radius = radius
		nav_obstacle.height = height
		# Optionally, set the obstacle's position to match the mesh's transform
		nav_obstacle.transform = navigation_obstacle_mesh.transform
		add_child(nav_obstacle)

func focussed() -> void:
	for child in get_children():
		if child.has_method("focussed"):
			child.focussed()

func unfocussed() -> void:
	for child in get_children():
		if child.has_method("unfocussed"):
			child.unfocussed()
