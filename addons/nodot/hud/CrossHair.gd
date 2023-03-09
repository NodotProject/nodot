@icon("../icons/crosshair.svg")
class_name CrossHair extends Nodot2D

@export var crosshair_sprite: Texture2D

func _ready():
  if is_instance_valid(WindowManager):
    WindowManager.connect("window_resized", _on_window_resized)
    WindowManager.bump()
    
func _enter_tree():
  var sprite2d = Sprite2D.new()
  sprite2d.name = "Sprite2D"
  sprite2d.set_texture(crosshair_sprite)
  add_child(sprite2d)
  
func _on_window_resized(new_size: Vector2):
  $Sprite2D.position = new_size / 2
  
