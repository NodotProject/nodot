class_name ThirdPersonCamera extends Camera3D

## Camera default offset
@export var camera_offset := Vector3(0, 2, 5)
## Camera should move in front of objects that block vision of the character
@export var always_in_front := true

@onready var parent: ThirdPersonCharacter = get_parent()

var raycast: RayCast3D

func _get_configuration_warnings() -> PackedStringArray:
  var warnings: PackedStringArray = []
  if !(get_parent() is ThirdPersonCharacter):
    warnings.append("Parent should be a ThirdPersonCharacter")
  return warnings
  
func _enter_tree():
  raycast = RayCast3D.new()
  add_child(raycast)

func _ready():
  position = camera_offset
  look_at(parent.position)
