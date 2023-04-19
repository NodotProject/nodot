class_name HealthBar3D extends Nodot3D

func _ready():
  var x: CanvasGroup = $CanvasGroup
  var y: Sprite3D = $Sprite3D
  y.texture = x.text
