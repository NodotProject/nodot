@tool
## Attaches a ProgressBar to a Health node
class_name HealthBar3D extends Projection3D

## The health node to watch for changes
@export var health_node: Health
## Adapt size to progress bar
@export var auto_size: bool = true

var progress_bar: ProgressBar


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if !Nodot.get_first_child_of_type(self, ProgressBar):
		warnings.append("Should have a ProgressBar as a child")

	if !health_node:
		warnings.append("Health Node should be assigned")

	return warnings


func _enter_tree() -> void:
	if !is_editor:
		connect("construction_complete", _construct)

		if health_node:
			health_node.connect("health_changed", health_changed)

			for child in get_children():
				if child is ProgressBar:
					progress_bar = child
					progress_bar.max_value = health_node.max_health
					progress_bar.value = health_node.current_health


func _construct() -> void:
	if progress_bar and auto_size:
		var resolution_size = progress_bar.size
		var ratio = resolution_size.x / resolution_size.y
		set_size(Vector2(projection_size.x, projection_size.x / ratio), resolution_size)


func health_changed(old_health: float, new_health: float):
	if progress_bar:
		progress_bar.set_value(new_health)
