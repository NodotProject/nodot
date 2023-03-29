@tool
@icon("../icons/crosshair.svg")
class_name CrossHair extends Nodot2D

## Places a crosshair in the center of the screen

@export var crosshair_sprite: Texture2D ## The crosshair texture

var is_editor: bool = Engine.is_editor_hint()

func _ready() -> void:
  if !is_editor and is_instance_valid(WindowManager):
    WindowManager.connect("window_resized", _on_window_resized)
    WindowManager.bump()

func _enter_tree() -> void:
  var sprite2d: Sprite2D = Sprite2D.new()
  sprite2d.name = "Sprite2D"
  sprite2d.set_texture(crosshair_sprite)
  add_child(sprite2d)

func _on_window_resized(new_size: Vector2) -> void:
  $Sprite2D.position = new_size / 2

func deactivate() -> void:
  visible = false

func activate() -> void:
  visible = true
