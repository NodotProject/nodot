@icon("../icons/crosshair.svg")
class_name CrossHair extends Nodot2D

## Places a crosshair in the center of the screen

@export var crosshair_sprite: Texture2D ## The crosshair texture

func _ready():
  if is_instance_valid(WindowManager):
    WindowManager.connect("window_resized", _on_window_resized)
    WindowManager.bump()
    
func _enter_tree():
  visible = false
  var sprite2d = Sprite2D.new()
  sprite2d.name = "Sprite2D"
  sprite2d.set_texture(crosshair_sprite)
  add_child(sprite2d)
  
func _on_window_resized(new_size: Vector2):
  $Sprite2D.position = new_size / 2
  
func deactivate():
  visible = false

func activate():
  visible = true
