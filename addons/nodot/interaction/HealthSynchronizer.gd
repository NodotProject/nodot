class_name HealthSynchronizer extends Node

@export var health_node: NodePath
@onready var health: Health = get_node(health_node)

# Synchronize the health value when it changes
@rpc("authority","call_local")
func synchronize_health(h: float) -> void:
	# h is new_health
	if multiplayer.is_server():
		health.set_health(h)
	else:
		health.current_health = h  # Directly set for clients
		
# Called when the health changes
func _on_health_changed(old_health: float, new_health: float) -> void:
	if multiplayer.is_server():
		rpc("synchronize_health", new_health)

func _ready() -> void:
	if not health_node:
		push_error("Health node path not set.")
		return
	if multiplayer.is_server():
		# Connect to the health changed signal
		health.connect("health_changed", Callable(self, "_on_health_changed"))
