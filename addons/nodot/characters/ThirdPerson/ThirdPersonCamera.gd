class_name ThirdPersonCamera extends Camera3D

## Camera default offset
@export var camera_offset := Vector3(0, 2, 5)
## Camera should move in front of objects that block vision of the character
@export var always_in_front := true

@onready var parent: Node3D = get_parent()

var raycast: RayCast3D

func _get_configuration_warnings() -> PackedStringArray:
  var warnings: PackedStringArray = []
  if !(get_parent() is ThirdPersonCharacter):
    warnings.append("Parent should be a ThirdPersonCharacter")
  return warnings
  
func _enter_tree() -> void:
  if always_in_front:
    raycast = RayCast3D.new()
    get_parent().add_child(raycast)

func _ready() -> void:
  position = camera_offset
  look_at(parent.position)
  
  raycast.position = parent.position
  raycast.target_position = position

func _physics_process(delta) -> void:
  if raycast:
    if raycast.is_colliding() and !raycast.hit_from_inside:
      global_position = raycast.get_collision_point()
    else:
      position = lerp(position, camera_offset, 0.1)
